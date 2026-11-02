import Foundation

/// Result of the start-up version check. Mirrors Android `UpgradeCheckState`.
enum UpgradeCheckState: Equatable {
    case checking
    case upToDate
    case updateRequired(message: String, storeUrl: String?)
}

/// iOS port of Android `ForceUpgradeChecker`: reads `min_version` from the J Coin project's
/// `app_config` table and blocks the app when this build is older. Every failure (no config,
/// network, HTTP error, bad JSON) lets the app continue, as on Android.
///
/// iOS reads its own row, `app_id = 'kanjijourney-ios'`, not Android's `kanjijourney`: the two apps
/// ship on different schedules, so an Android minimum must never lock iOS testers out of a build
/// that has no newer iOS version yet. With no iOS row the check always passes.
enum ForceUpgradeChecker {

    static let appId = "kanjijourney-ios"
    static let defaultMessage = "A new version of KanjiJourney is available. Please update to continue using the app."

    /// CFBundleShortVersionString. CI sets it from the repo's VERSION file (MARKETING_VERSION).
    static var currentAppVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    private struct AppConfigRow: Decodable {
        let minVersion: String
        let forceUpgradeMessage: String?
        let storeUrl: String?

        enum CodingKeys: String, CodingKey {
            case minVersion = "min_version"
            case forceUpgradeMessage = "force_upgrade_message"
            case storeUrl = "store_url"
        }
    }

    static func check(currentVersion: String, configuration: Configuration) async -> UpgradeCheckState {
        guard let request = makeRequest(configuration: configuration) else {
            NSLog("KanjiJourney [ForceUpgrade]: J Coin config missing, skipping version check")
            return .upToDate
        }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                NSLog("KanjiJourney [ForceUpgrade]: Version check got HTTP %d, allowing app", status)
                return .upToDate
            }
            guard let config = try JSONDecoder().decode([AppConfigRow].self, from: data).first else {
                NSLog("KanjiJourney [ForceUpgrade]: No app_config for %@, allowing app", appId)
                return .upToDate
            }
            guard isVersionBelow(currentVersion, config.minVersion) else {
                NSLog("KanjiJourney [ForceUpgrade]: Version %@ meets minimum %@", currentVersion, config.minVersion)
                return .upToDate
            }
            NSLog("KanjiJourney [ForceUpgrade]: Version %@ below minimum %@", currentVersion, config.minVersion)
            return .updateRequired(message: config.forceUpgradeMessage ?? defaultMessage, storeUrl: config.storeUrl)
        } catch {
            // Type only: the request carries the API key header
            NSLog("KanjiJourney [ForceUpgrade]: Version check failed (%@), allowing app", String(describing: type(of: error)))
            return .upToDate
        }
    }

    /// GET <supabase>/rest/v1/app_config with only the three columns it reads, so a new column on
    /// the table cannot break decoding (the Android check fails on `app_id`, BUG-013).
    static func makeRequest(configuration: Configuration) -> URLRequest? {
        let key = configuration.supabaseAnonKey
        guard !key.isEmpty,
              var components = URLComponents(string: configuration.supabaseUrl),
              components.scheme == "https", components.host?.isEmpty == false else { return nil }
        let basePath = components.path.hasSuffix("/") ? String(components.path.dropLast()) : components.path
        components.path = basePath + "/rest/v1/app_config"
        components.queryItems = [
            URLQueryItem(name: "select", value: "min_version,force_upgrade_message,store_url"),
            URLQueryItem(name: "app_id", value: "eq.\(appId)"),
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.setValue(key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    /// Numeric dotted compare, missing parts count as 0. Same rule as Android `isVersionBelow`.
    static func isVersionBelow(_ current: String, _ minimum: String) -> Bool {
        let c = current.split(separator: ".").compactMap { Int($0) }
        let m = minimum.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(c.count, m.count) {
            let cv = i < c.count ? c[i] : 0
            let mv = i < m.count ? m[i] : 0
            if cv < mv { return true }
            if cv > mv { return false }
        }
        return false
    }
}
