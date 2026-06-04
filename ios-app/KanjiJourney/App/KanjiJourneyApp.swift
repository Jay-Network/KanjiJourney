import SwiftUI

@main
struct KanjiJourneyApp: App {
    @StateObject private var appState = AppState()

    init() {
        GlassTypography.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}

/// App state — starts with splash, then tries KMP init on a background thread.
/// If KMP crashes, the app survives and shows a mock UI instead.
class AppState: ObservableObject {
    enum Phase {
        case splash
        case mockHome
        case ready(AppContainer)
        case failed(String)
    }

    @Published var phase: Phase = .splash
    @Published var diagnosticLog: [String] = []

    func onSplashComplete() {
        // Go straight to mock home — KMP init happens in background
        phase = .mockHome
    }

    func tryKMPInit() {
        log("KMPBridge.initialize()...")
        do {
            try ObjCExceptionCatcher.catchVoid { KMPBridge.initialize() }
        } catch {
            log("KMPBridge EXCEPTION: \(error.localizedDescription)")
            phase = .failed("KMP bridge init failed:\n\(error.localizedDescription)")
            return
        }
        log("KMPBridge OK")

        log("Creating AppContainer...")
        CrashDiagnostic.begin()

        // Catch ObjC/KMP exceptions that Swift can't normally catch
        let container: AppContainer
        do {
            container = try ObjCExceptionCatcher.catch { AppContainer() }
        } catch {
            CrashDiagnostic.step("AppContainer EXCEPTION: \(error.localizedDescription)")
            log("AppContainer EXCEPTION: \(error.localizedDescription)")
            phase = .failed("KMP initialization failed:\n\(error.localizedDescription)")
            return
        }

        CrashDiagnostic.complete()

        if let error = container.initError {
            log("AppContainer FAILED: \(error)")
            phase = .failed(error)
        } else {
            log("AppContainer OK — switching to full app")
            // Register background task — wrap in exception catcher too
            do {
                try ObjCExceptionCatcher.catchVoid { container.syncService.registerBackgroundTask() }
                log("BGTask registered OK")
            } catch {
                log("BGTask registration failed (non-fatal): \(error.localizedDescription)")
                // Non-fatal — app can still work without background sync
            }
            phase = .ready(container)
        }
    }

    func log(_ msg: String) {
        let entry = "[\(formattedTime())] \(msg)"
        diagnosticLog.append(entry)
        NSLog("KanjiJourney: %@", msg)
    }

    private func formattedTime() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f.string(from: Date())
    }
}

struct AppRootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.phase {
        case .splash:
            SplashView(onSplashComplete: {
                appState.onSplashComplete()
            })

        case .mockHome:
            MockHomeView()
                .environmentObject(appState)

        case .ready(let container):
            AppNavigation()
                .environmentObject(container)

        case .failed(let error):
            errorView(error)
        }
    }

    private func errorView(_ error: String) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.orange)
                Text("KanjiJourney")
                    .font(.title).bold()
                Text("Database initialization failed")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Diagnostic Log:")
                        .font(.caption).bold()
                    ForEach(appState.diagnosticLog, id: \.self) { line in
                        Text(line)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)

                Button("Try Again") {
                    appState.phase = .mockHome
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
    }
}

/// Mock home screen — NO KMP, NO database, NO shared-core.
/// Pure SwiftUI so we can confirm the app runs on iPad.
/// Has a button to attempt KMP initialization when ready.
struct MockHomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var isInitializing = false
    @State private var showCalligraphy = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Welcome card
                    GlassCard {
                        VStack(spacing: 8) {
                            Image("JWorksLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                            Text("Welcome to KanjiJourney!")
                                .font(GlassTypography.headlineSmall)
                                .foregroundColor(GlassColors.textPrimary)
                            Text("Gamified Kanji Learning")
                                .font(GlassTypography.bodyMedium)
                                .foregroundColor(GlassColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                    }

                    Text("Game Modes")
                        .font(GlassTypography.titleMedium)
                        .foregroundColor(GlassColors.textPrimary)

                    mockModeCard(title: "Recognition", desc: "Identify kanji from choices", color: Color(hex: 0x2196F3), icon: "eye.fill", available: false)

                    Button(action: { showCalligraphy = true }) {
                        mockModeCardContent(title: "書道 Writing", desc: "Practice calligraphy with AI feedback", color: Color(hex: 0x4CAF50), icon: "pencil.tip", available: true)
                    }
                    .buttonStyle(.plain)

                    mockModeCard(title: "Vocabulary", desc: "Learn words using kanji", color: Color(hex: 0xFF9800), icon: "book.fill", available: false)
                    mockModeCard(title: "Camera Challenge", desc: "Find kanji in the real world", color: Color(hex: 0x9C27B0), icon: "camera.fill", available: false)

                    Text("Study")
                        .font(GlassTypography.titleMedium)
                        .foregroundColor(GlassColors.textPrimary)

                    mockModeCard(title: "Kana", desc: "Learn Hiragana & Katakana", color: Color(hex: 0xE91E63), icon: "textformat.abc", available: false)
                    mockModeCard(title: "Radicals", desc: "Master kanji building blocks", color: Color(hex: 0x795548), icon: "square.grid.3x3.fill", available: false)

                    Spacer().frame(height: 16)

                    Button(action: {
                        isInitializing = true
                        appState.tryKMPInit()
                    }) {
                        GlassCard(borderColor: GlassBrand.current.opacity(0.45)) {
                            HStack {
                                if isInitializing {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "play.fill")
                                        .foregroundColor(GlassBrand.current)
                                }
                                Text(isInitializing ? "Loading database..." : "Unlock All Modes")
                                    .font(GlassTypography.titleMedium)
                                    .foregroundColor(GlassColors.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                    }
                    .disabled(isInitializing)
                    .opacity(isInitializing ? 0.5 : 1.0)

                    if !appState.diagnosticLog.isEmpty {
                        GlassCard(borderColor: Color.white.opacity(0.10)) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Init Log:")
                                    .font(GlassTypography.labelSmall)
                                    .foregroundColor(GlassColors.textSecondary)
                                ForEach(appState.diagnosticLog, id: \.self) { line in
                                    Text(line)
                                        .font(.system(.caption2, design: .monospaced))
                                        .foregroundColor(GlassColors.textMuted)
                                }
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Spacer().frame(height: 32)
                }
                .padding(16)
            }
            .background(GlassColors.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("KanjiJourney")
                        .font(GlassTypography.titleSmall)
                        .foregroundColor(GlassColors.textPrimary)
                }
            }
            .toolbarBackground(GlassColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showCalligraphy) {
                NavigationStack {
                    MockCalligraphyView()
                }
            }
        }
    }

    private func mockModeCard(title: String, desc: String, color: Color, icon: String, available: Bool) -> some View {
        mockModeCardContent(title: title, desc: desc, color: color, icon: icon, available: available)
            .opacity(available ? 1.0 : 0.5)
    }

    private func mockModeCardContent(title: String, desc: String, color: Color, icon: String, available: Bool = true) -> some View {
        GlassCard(borderColor: color.opacity(available ? 0.40 : 0.15)) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(GlassTypography.labelLarge)
                            .foregroundColor(GlassColors.textPrimary)
                        if available {
                            Text("READY")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(hex: 0x4CAF50))
                                .cornerRadius(4)
                        }
                    }
                    Text(desc)
                        .font(GlassTypography.bodySmall)
                        .foregroundColor(GlassColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(available ? color : GlassColors.textMuted)
            }
            .padding(12)
        }
    }
}
