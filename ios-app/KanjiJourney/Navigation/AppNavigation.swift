import SwiftUI
import SharedCore

/// Full navigation host matching Android KanjiJourneyNavHost.
/// Handles all 23+ routes, the feedback sheet, and post-login routing.
@MainActor
struct AppNavigation: View {
    @EnvironmentObject var container: AppContainer
    @EnvironmentObject var deepLinks: DeepLinkQueue
    @State private var path = NavigationPath()
    @State private var showSplash = true
    @State private var isAuthenticated = false
    @State private var deepLinkDiscovery: DeepLinkDiscovery?
    @State private var deepLinkMessage: String?

    private struct DeepLinkDiscovery: Identifiable {
        let item: CollectedItem
        let literal: String
        var id: Int32 { item.itemId }
    }

    // Feedback: opened from the main tabs' top bar (FeedbackToolbarButton), no floating button
    @StateObject private var feedbackViewModel = FeedbackViewModel()

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                Group {
                    if showSplash {
                        SplashView(onSplashComplete: {
                            showSplash = false
                        })
                    } else if isAuthenticated {
                        MainTabView(navigateTo: navigate)
                    } else {
                        LoginView(
                            onLoginSuccess: { navigateAfterLogin() },
                            onContinueWithoutAccount: { navigateAfterLogin() }
                        )
                    }
                }
                .navigationDestination(for: NavRoute.self) { route in
                    destinationView(for: route)
                }
            }
        }
        .sheet(
            isPresented: $feedbackViewModel.isDialogOpen,
            onDismiss: { feedbackViewModel.closeDialog() }
        ) {
            FeedbackDialogView(
                viewModel: feedbackViewModel,
                onDismiss: { feedbackViewModel.closeDialog() }
            )
        }
        .task {
            feedbackViewModel.configure(container: container)
            isAuthenticated = (try? await container.authRepository.getCurrentUserId()) != nil
        }
        .environmentObject(container)
        .environmentObject(feedbackViewModel)
        .onAppear { processPendingDeepLink() }
        .onChange(of: showSplash) { _ in processPendingDeepLink() }
        .onChange(of: isAuthenticated) { _ in processPendingDeepLink() }
        .onChange(of: deepLinks.pending) { _ in processPendingDeepLink() }
        .fullScreenCover(item: $deepLinkDiscovery, onDismiss: finishDeepLink) { discovery in
            DiscoveryOverlay(
                discoveredItem: discovery.item,
                kanjiLiteral: discovery.literal,
                kanjiMeaning: nil,
                onDismiss: { deepLinkDiscovery = nil }
            )
        }
        .alert("KanjiJourney", isPresented: Binding(
            get: { deepLinkMessage != nil },
            set: { presented in
                if !presented {
                    deepLinkMessage = nil
                    finishDeepLink()
                }
            }
        )) {
            Button("OK", role: .cancel) { }
                .accessibilityLabel("Dismiss deep link result")
        } message: {
            Text(deepLinkMessage ?? "")
        }
    }

    // MARK: - Deep links (all mutations stay in local SharedCore repositories)

    private func finishDeepLink() {
        deepLinks.finish()
        processPendingDeepLink()
    }

    private func processPendingDeepLink() {
        guard let link = deepLinks.beginNext(isReady: !showSplash && isAuthenticated) else { return }
        Task { @MainActor in
            do {
                switch link {
                case .collect(let kanjiId, let source):
                    let collected = try await container.collectionRepository.isCollected(itemId: kanjiId, itemType: .kanji)
                    if collected.boolValue {
                        deepLinkMessage = "Already in collection!"
                        return
                    }
                    guard let kanji = try await container.kanjiRepository.getKanjiById(id: kanjiId) else {
                        deepLinkMessage = "Kanji not found."
                        return
                    }
                    let item = CollectedItem(
                        itemId: kanjiId, itemType: .kanji,
                        rarity: RarityCalculator.shared.calculateKanjiRarity(
                            grade: kanji.grade, frequency: kanji.frequency, strokeCount: kanji.strokeCount
                        ),
                        itemLevel: 1, itemXp: 0,
                        discoveredAt: Int64(Date().timeIntervalSince1970), source: source
                    )
                    try await container.collectionRepository.collect(item: item)
                    NotificationCenter.default.post(name: .localKanjiDataDidChange, object: nil)
                    deepLinkDiscovery = DeepLinkDiscovery(item: item, literal: kanji.literal)

                case .importKanji(let literals, let source):
                    try await container.importKanjiUseCase.receiveKanji(literals: literals, sourceApp: source)
                    let result = try await container.importKanjiUseCase.processPending()
                    NotificationCenter.default.post(name: .localKanjiDataDidChange, object: nil)
                    deepLinkMessage = KanjiDeepLink.importMessage(
                        imported: result.imported, alreadyKnown: result.alreadyKnown, notFound: result.notFound
                    )

                case .subscription:
                    navigate(to: .subscriptionFromDeepLink)
                    finishDeepLink()
                }
            } catch {
                deepLinkMessage = "Could not finish opening this link. Please try again."
            }
        }
    }

    // MARK: - Post-login routing (placement test check)
    private func navigateAfterLogin() {
        let assessmentDone = UserDefaults.standard.bool(forKey: "assessment_completed")
        isAuthenticated = true
        if !assessmentDone {
            path.append(NavRoute.placementTest)
        }
    }

    // MARK: - Navigation helper
    func navigate(to route: NavRoute) {
        path.append(route)
    }

    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func navigateToRoot() {
        path = NavigationPath()
    }

    // MARK: - Route → View mapping
    @ViewBuilder
    private func destinationView(for route: NavRoute) -> some View {
        switch route {
        case .splash:
            SplashView(onSplashComplete: { showSplash = false })

        case .login:
            LoginView(
                onLoginSuccess: {
                    isAuthenticated = true
                    path = NavigationPath()
                },
                onContinueWithoutAccount: {
                    isAuthenticated = true
                    path = NavigationPath()
                }
            )

        case .home:
            MainTabView(navigateTo: navigate)

        case .placementTest:
            PlacementTestView(
                onBack: { navigateBack() },
                onComplete: {
                    UserDefaults.standard.set(true, forKey: "assessment_completed")
                    path = NavigationPath()
                }
            )

        // MARK: - Kanji Detail
        case .kanjiDetail(let kanjiId):
            KanjiDetailView(
                kanjiId: kanjiId,
                onBack: { navigateBack() },
                onPracticeWriting: { id in navigate(to: .writingTargeted(kanjiId: id)) },
                onPracticeCamera: { id in navigate(to: .cameraTargeted(kanjiId: id)) }
            )

        // MARK: - Game Modes
        case .recognition:
            RecognitionView(onBack: { navigateBack() })

        case .recognitionTargeted(let kanjiId):
            RecognitionView(targetKanjiId: kanjiId, onBack: { navigateBack() })

        case .writing:
            WritingView(onBack: { navigateBack() })

        case .writingTargeted(let kanjiId):
            WritingView(targetKanjiId: kanjiId, onBack: { navigateBack() })

        case .vocabulary:
            VocabularyView(onBack: { navigateBack() })

        case .vocabularyTargeted(let kanjiId):
            VocabularyView(targetKanjiId: kanjiId, onBack: { navigateBack() })

        case .camera:
            CameraChallengeView(
                onBack: { navigateBack() },
                onJournal: { navigate(to: .fieldJournal) }
            )

        case .cameraTargeted(let kanjiId):
            CameraChallengeView(
                targetKanjiId: kanjiId,
                onBack: { navigateBack() },
                onJournal: { navigate(to: .fieldJournal) }
            )

        // MARK: - Kana Modes
        case .kanaRecognition(let kanaType):
            KanaRecognitionView(kanaType: kanaType == "hiragana" ? .hiragana : .katakana, onBack: { navigateBack() })

        case .kanaWriting(let kanaType):
            // iPad: uses calligraphy canvas. iPhone: not available (excluded at build time)
            KanaRecognitionView(kanaType: kanaType == "hiragana" ? .hiragana : .katakana, onBack: { navigateBack() })

        // MARK: - Radical Modes
        case .radicalRecognition:
            RadicalRecognitionView(onBack: { navigateBack() })

        case .radicalBuilder:
            RadicalBuilderView(onBack: { navigateBack() })

        case .radicalDetail(let radicalId):
            RadicalDetailView(
                radicalId: radicalId,
                onBack: { navigateBack() },
                onKanjiClick: { kanjiId in navigate(to: .kanjiDetail(kanjiId: kanjiId)) }
            )

        // MARK: - Collection & Flashcards
        case .collection:
            CollectionView(
                onBack: { navigateBack() },
                onKanjiClick: { kanjiId in navigate(to: .kanjiDetail(kanjiId: kanjiId)) }
            )

        case .flashcards:
            FlashcardView(
                onBack: { navigateBack() },
                onStudy: { deckId in navigate(to: .flashcardStudy(deckId: deckId)) },
                onKanjiClick: { kanjiId in navigate(to: .kanjiDetail(kanjiId: kanjiId)) }
            )

        case .flashcardStudy(let deckId):
            FlashcardStudyView(deckId: deckId, onBack: { navigateBack() })

        // MARK: - Progress & Achievements
        case .progress:
            KQProgressView(onBack: { navigateBack() })

        case .achievements:
            AchievementsView(onBack: { navigateBack() })

        // MARK: - Shop & Subscription
        case .shop:
            ShopView(onBack: { navigateBack() })

        case .subscription:
            SubscriptionView(onBack: { navigateBack() })

        case .subscriptionFromDeepLink:
            SubscriptionView(remoteStatusEnabled: false, onBack: { navigateBack() })

        // MARK: - Settings
        case .settings:
            SettingsView(
                onBack: { navigateBack() },
                onDevChat: { navigate(to: .devChat) },
                onRetakeAssessment: { navigate(to: .placementTest) }
            )

        // MARK: - Word Detail
        case .wordDetail(let wordId):
            WordDetailView(
                wordId: wordId,
                onBack: { navigateBack() },
                onKanjiClick: { kanjiId in navigate(to: .kanjiDetail(kanjiId: kanjiId)) }
            )

        // MARK: - Test Mode
        case .testMode:
            TestModeView(onBack: { navigateBack() })

        // MARK: - Dev & Feedback
        case .devChat:
            DevChatView(onBack: { navigateBack() })

        case .fieldJournal:
            FieldJournalView(onBack: { navigateBack() })

        // MARK: - Calligraphy (iPad-only: Calligraphy/ is excluded from the iPhone target)
        #if IPAD_TARGET
        case .calligraphySession(let kanji, let paths):
            CalligraphySessionView(
                kanjiLiteral: kanji,
                strokePaths: paths
            )
        #else
        case .calligraphySession:
            EmptyView()
        #endif
        }
    }
}
