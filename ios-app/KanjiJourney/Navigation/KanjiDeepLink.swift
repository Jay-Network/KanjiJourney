import Foundation
import Combine

extension Notification.Name {
    static let localKanjiDataDidChange = Notification.Name("localKanjiDataDidChange")
}

/// Android-compatible URL payloads. Invalid/unsupported URLs never enter the queue.
enum KanjiDeepLink: Equatable {
    case collect(kanjiId: Int32, source: String)
    case importKanji(literals: [String], source: String)
    case subscription

    init?(url: URL) {
        guard url.scheme?.lowercased() == "kanjijourney",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        func query(_ name: String) -> String? {
            components.queryItems?.first(where: { $0.name == name })?.value
        }
        switch components.host?.lowercased() {
        case "collect":
            guard let value = query("kanji_id"), let id = Int32(value) else { return nil }
            self = .collect(kanjiId: id, source: query("source") ?? "kanjilens")
        case "import":
            let literals = (query("kanji") ?? "").components(separatedBy: ",")
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            guard !literals.isEmpty else { return nil }
            self = .importKanji(literals: literals, source: query("source") ?? "kanjisage")
        case "subscription":
            self = .subscription
        default:
            return nil
        }
    }

    static func importMessage(imported: Int32, alreadyKnown: Int32, notFound: Int32) -> String {
        var parts: [String] = []
        if imported > 0 { parts.append("\(imported) kanji added to study deck") }
        if alreadyKnown > 0 { parts.append("\(alreadyKnown) already studying") }
        if notFound > 0 { parts.append("\(notFound) not found") }
        return parts.isEmpty ? "No kanji to import." : parts.joined(separator: ", ")
    }
}

/// App-scoped so URLs survive splash/KMP initialization/login and cannot overwrite each other.
@MainActor
final class DeepLinkQueue: ObservableObject {
    @Published private(set) var pending: [KanjiDeepLink] = []
    private(set) var isProcessing = false

    func enqueue(_ url: URL) {
        guard let link = KanjiDeepLink(url: url) else { return }
        pending.append(link)
    }

    func beginNext(isReady: Bool) -> KanjiDeepLink? {
        guard isReady, !isProcessing, !pending.isEmpty else { return nil }
        isProcessing = true
        return pending.removeFirst()
    }

    // Keep the next link queued until the user dismisses the current result.
    func finish() { isProcessing = false }
}
