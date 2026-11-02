import SwiftUI

/// Full-screen block shown when this build is below the minimum version. Port of Android
/// `ForceUpgradeScreen`: dark slate background, teal accent, one "Update Now" button.
struct ForceUpgradeView: View {
    let message: String
    let storeUrl: String?

    private static let background = Color(hex: 0x0F172A)
    private static let teal = Color(hex: 0x0D9488)
    // iOS ships through TestFlight only for now; the TestFlight app lists the newer build.
    private static let defaultUpdateUrl = "itms-beta://"

    var body: some View {
        ZStack {
            Self.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Image("JWorksLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .accessibilityLabel("KanjiJourney")

                Spacer().frame(height: 32)

                Text("Update Required")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Self.teal)
                    .accessibilityAddTraits(.isHeader)

                Spacer().frame(height: 16)

                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Spacer().frame(height: 40)

                Button(action: openUpdate) {
                    Text("Update Now")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Self.teal)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxWidth: 480)
            .padding(32)
        }
    }

    private func openUpdate() {
        guard let url = URL(string: storeUrl ?? Self.defaultUpdateUrl) else { return }
        UIApplication.shared.open(url)
    }
}
