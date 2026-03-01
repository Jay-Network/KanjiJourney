import SwiftUI
import SharedCore

struct WritingView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = WritingViewModel()
    var targetKanjiId: Int32? = nil
    var onBack: () -> Void = {}

    @State private var showDiscoveryOverlay = false
    @State private var discoveredItem: CollectedItem? = nil

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            switch viewModel.gameState {
            case .idle:
                setupContent

            case .preparing:
                VStack(spacing: 16) {
                    Text("Preparing writing questions...").font(KanjiJourneyTheme.titleMedium)
                    ProgressView()
                }

            case .awaitingAnswer(let q):
                writingQuestionContent(q)
                    .onAppear { showDiscoveryOverlay = false }

            case .showingResult(let result):
                writingResultContent(result)
                    .onAppear {
                        if let item = result.discoveredItem {
                            discoveredItem = item
                            showDiscoveryOverlay = true
                        }
                    }

            case .sessionComplete(let stats):
                sessionCompleteContent(stats)

            case .error(let message):
                VStack(spacing: 16) {
                    Text(message).font(KanjiJourneyTheme.bodyLarge).multilineTextAlignment(.center)
                    Button("Go Back", action: onBack).buttonStyle(.bordered)
                }.padding(24)
            }

            if showDiscoveryOverlay, let item = discoveredItem {
                DiscoveryOverlay(
                    discoveredItem: item,
                    kanjiLiteral: nil,
                    kanjiMeaning: nil,
                    onDismiss: { showDiscoveryOverlay = false }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) { Image(systemName: "chevron.left"); Text("Back") }
            }
            ToolbarItem(placement: .principal) { Text("Writing").font(.headline) }
        }
        .task {
            viewModel.start(container: container, targetKanjiId: targetKanjiId)
        }
    }

    // MARK: - Setup Screen

    private var setupContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)

                    Text("Writing Practice")
                        .font(KanjiJourneyTheme.headlineMedium).fontWeight(.bold)

                    Text("Trace kanji stroke by stroke with guided references")
                        .font(KanjiJourneyTheme.bodyLarge)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                        .multilineTextAlignment(.center)

                    // AI Feedback toggle
                    toggleCard(
                        title: "AI Handwriting Feedback",
                        subtitle: "Gemini analyzes your strokes after each submission",
                        isOn: Binding(get: { viewModel.aiEnabled }, set: { viewModel.setAiEnabled($0) })
                    )

                    // Language toggle (when AI enabled)
                    if viewModel.aiEnabled {
                        toggleCard(
                            title: "Feedback Language",
                            subtitle: viewModel.aiFeedbackLanguage == "ja" ? "Japanese (日本語)" : "English",
                            isOn: Binding(
                                get: { viewModel.aiFeedbackLanguage == "ja" },
                                set: { viewModel.setAiFeedbackLanguage($0 ? "ja" : "en") }
                            )
                        )
                    }

                    // Admin difficulty override
                    if viewModel.isAdmin {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Debug: Writing Difficulty")
                                .font(KanjiJourneyTheme.bodyMedium).fontWeight(.bold)
                                .foregroundColor(Color(hex: 0xE65100))

                            HStack(spacing: 6) {
                                difficultyButton("Auto", selected: viewModel.adminDifficultyOverride == nil) {
                                    viewModel.setAdminDifficultyOverride(nil)
                                }
                                ForEach(WritingDifficulty.allCases, id: \.rawValue) { diff in
                                    difficultyButton(diff.rawValue, selected: viewModel.adminDifficultyOverride == diff) {
                                        viewModel.setAdminDifficultyOverride(diff)
                                    }
                                }
                            }
                        }
                        .padding(12)
                        .background(Color(hex: 0xFFF3E0))
                        .cornerRadius(12)
                    }

                    // Start button
                    Button {
                        let len = UserDefaults.standard.integer(forKey: "session_length")
                        viewModel.startGame(questionCount: len > 0 ? len : 10)
                    } label: {
                        Text("Start Practice").font(.system(size: 18)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 56)
                            .background(KanjiJourneyTheme.primary).cornerRadius(12)
                    }

                    Spacer(minLength: 40)
                }
                .padding(24)
            }
        }
    }

    private func toggleCard(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(KanjiJourneyTheme.bodyLarge).fontWeight(.medium)
                Text(subtitle).font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(KanjiJourneyTheme.primary)
        }
        .padding(16)
        .background(KanjiJourneyTheme.surfaceVariant)
        .cornerRadius(12)
    }

    private func difficultyButton(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 11))
                .frame(maxWidth: .infinity).frame(height: 32)
                .background(selected ? Color(hex: 0xE65100).opacity(0.15) : Color.clear)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Writing Question

    private func writingQuestionContent(_ q: GameQuestionState) -> some View {
        let totalRefStrokes = q.strokePaths.count
        let currentStrokeIndex = viewModel.completedStrokes.count

        return ScrollView {
            VStack(spacing: 8) {
                // Progress + stats
                HStack {
                    Text("\(q.questionNumber) / \(q.totalQuestions)").font(KanjiJourneyTheme.bodyMedium)
                    Spacer()
                    if q.currentCombo > 1 {
                        Text("\(q.currentCombo)x combo")
                            .font(KanjiJourneyTheme.bodyMedium).fontWeight(.bold)
                            .foregroundColor(KanjiJourneyTheme.tertiary)
                    }
                    Text("\(q.sessionXp) XP")
                        .font(KanjiJourneyTheme.bodyMedium).foregroundColor(KanjiJourneyTheme.primary)
                }

                ProgressView(value: Float(q.questionNumber), total: Float(q.totalQuestions))
                    .tint(KanjiJourneyTheme.primary)

                Text(q.questionText)
                    .font(KanjiJourneyTheme.titleMedium)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)

                // Stroke counter + difficulty
                HStack {
                    Text("Stroke \(min(currentStrokeIndex + 1, totalRefStrokes)) / \(totalRefStrokes)")
                        .font(KanjiJourneyTheme.bodyMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    Spacer()
                    Text(viewModel.effectiveDifficulty.rawValue)
                        .font(KanjiJourneyTheme.bodySmall)
                        .foregroundColor(difficultyColor)
                }

                // Drawing canvas
                WritingDrawingCanvas(
                    referenceStrokePaths: q.strokePaths,
                    currentStrokeIndex: currentStrokeIndex,
                    completedStrokes: viewModel.completedStrokes,
                    activeStroke: viewModel.activeStroke,
                    writingDifficulty: viewModel.effectiveDifficulty,
                    onDragStart: { viewModel.onDragStart($0) },
                    onDrag: { viewModel.onDrag($0) },
                    onDragEnd: { viewModel.onDragEnd() },
                    onSizeChanged: { viewModel.onCanvasSizeChanged($0) }
                )
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 16)

                // Action buttons
                HStack(spacing: 8) {
                    Button(action: { viewModel.undoLastStroke() }) {
                        Text("Undo").frame(maxWidth: .infinity).frame(height: 40)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.completedStrokes.isEmpty)

                    Button(action: { viewModel.clearStrokes() }) {
                        Text("Clear").frame(maxWidth: .infinity).frame(height: 40)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.completedStrokes.isEmpty)

                    Button(action: { viewModel.submitDrawing() }) {
                        Text("Submit").foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 40)
                            .background(KanjiJourneyTheme.primary).cornerRadius(8)
                    }
                    .disabled(viewModel.completedStrokes.isEmpty)
                }
            }
            .padding(16)
        }
    }

    private var difficultyColor: Color {
        switch viewModel.effectiveDifficulty {
        case .guided: return KanjiJourneyTheme.primary
        case .noOrder: return KanjiJourneyTheme.tertiary
        case .blank: return KanjiJourneyTheme.error
        }
    }

    // MARK: - Writing Result

    private func writingResultContent(_ result: GameResultState) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Correct kanji display
                RoundedRectangle(cornerRadius: 12)
                    .fill(result.isCorrect ? Color(hex: 0xE8F5E9) : Color(hex: 0xFFEBEE))
                    .shadow(radius: 4)
                    .frame(width: 160, height: 160)
                    .overlay(
                        KanjiText(
                            text: result.question.kanjiLiteral,
                            font: .system(size: 80, design: .serif)
                        )
                    )

                Text(result.isCorrect ? "+\(result.xpGained) XP" : "Incorrect")
                    .font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
                    .foregroundColor(result.isCorrect ? KanjiJourneyTheme.tertiary : KanjiJourneyTheme.error)

                Text(result.isCorrect ? "Well drawn!" : "Keep practicing! The correct kanji is shown above.")
                    .font(KanjiJourneyTheme.bodyLarge)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)

                // Color-coded stroke image
                if let imageBase64 = viewModel.analyzedImageBase64 ?? viewModel.aiFeedback?.analyzedImageBase64,
                   let data = Data(base64Encoded: imageBase64),
                   let uiImage = UIImage(data: data) {
                    Text("Your Strokes (color-coded)")
                        .font(KanjiJourneyTheme.labelMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 160, height: 160)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                }

                // AI Feedback
                if viewModel.aiLoading {
                    ProgressView().frame(maxWidth: .infinity)
                    Text("AI analyzing your handwriting...")
                        .font(KanjiJourneyTheme.labelMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }

                if let feedback = viewModel.aiFeedback, feedback.isAvailable {
                    aiFeedbackCard(feedback)
                }

                // Next button
                Button(action: { viewModel.nextQuestion() }) {
                    Text("Next").font(.system(size: 18)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(KanjiJourneyTheme.primary).cornerRadius(12)
                }
            }
            .padding(16)
        }
    }

    private func aiFeedbackCard(_ feedback: HandwritingFeedback) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("AI Feedback")
                    .font(KanjiJourneyTheme.labelMedium).fontWeight(.bold)
                Spacer()
                Text(String(repeating: "\u{2605}", count: feedback.qualityRating) +
                     String(repeating: "\u{2606}", count: 5 - feedback.qualityRating))
                    .font(.system(size: 16))
            }

            if !feedback.overallComment.isEmpty {
                Text(feedback.overallComment).font(KanjiJourneyTheme.bodyMedium)
            }

            ForEach(feedback.strokeFeedback, id: \.self) { tip in
                Text("\u{2022} \(tip)")
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            }

            // Report button
            HStack {
                Spacer()
                if viewModel.aiReportSubmitted {
                    Text("Reported - thank you!")
                        .font(KanjiJourneyTheme.labelSmall)
                        .foregroundColor(KanjiJourneyTheme.primary)
                } else {
                    Button(action: { viewModel.reportAiFeedback() }) {
                        Text("Report Incorrect AI")
                            .font(.system(size: 12))
                            .foregroundColor(KanjiJourneyTheme.error)
                    }
                    .buttonStyle(.bordered)
                    .tint(KanjiJourneyTheme.error)
                }
            }
        }
        .padding(12)
        .background(KanjiJourneyTheme.surfaceVariant)
        .cornerRadius(12)
    }

    // MARK: - Session Complete

    private func sessionCompleteContent(_ stats: GameSessionStats) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Session Complete!").font(KanjiJourneyTheme.headlineMedium).fontWeight(.bold)

            VStack(spacing: 12) {
                statRow("Cards Studied", "\(stats.cardsStudied)")
                statRow("Correct", "\(stats.correctCount) / \(stats.cardsStudied)")
                statRow("Accuracy", "\(stats.accuracy)%")
                statRow("Best Combo", "\(stats.comboMax)x")
                statRow("XP Earned", "+\(stats.xpEarned)")
                statRow("Duration", stats.formattedDuration)

                if let result = viewModel.sessionResult {
                    Divider().padding(.vertical, 4)
                    if result.coinsEarned > 0 {
                        Text("+\(result.coinsEarned) J Coins")
                            .font(KanjiJourneyTheme.titleMedium).fontWeight(.bold)
                            .foregroundColor(KanjiJourneyTheme.xpGold)
                    }
                    if result.leveledUp {
                        Text("Level Up! -> Level \(result.newLevel)")
                            .font(KanjiJourneyTheme.titleMedium).fontWeight(.bold)
                            .foregroundColor(KanjiJourneyTheme.tertiary)
                    }
                    if result.streakIncreased {
                        Text("\(result.currentStreak) day streak!")
                            .font(KanjiJourneyTheme.bodyLarge).foregroundColor(KanjiJourneyTheme.primary)
                    }
                    if let message = result.adaptiveMessage {
                        Text(message).font(KanjiJourneyTheme.bodyLarge).fontWeight(.bold)
                            .foregroundColor(KanjiJourneyTheme.secondary)
                    }
                }
            }
            .padding(20)
            .background(KanjiJourneyTheme.surface)
            .cornerRadius(12)

            Button { viewModel.reset(); onBack() } label: {
                Text("Done").font(.system(size: 18)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(KanjiJourneyTheme.primary).cornerRadius(12)
            }
            Spacer()
        }
        .padding(24)
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(KanjiJourneyTheme.bodyLarge).foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            Spacer()
            Text(value).font(KanjiJourneyTheme.bodyLarge).fontWeight(.bold)
        }
    }
}
