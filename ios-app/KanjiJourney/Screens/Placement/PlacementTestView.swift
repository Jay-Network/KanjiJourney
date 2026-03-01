import SwiftUI
import SharedCore

/// Placement test screen. Mirrors Android's PlacementTestScreen.kt.
/// Intro, timed questions with animated feedback, results with stage breakdown.
struct PlacementTestView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = PlacementTestViewModel()
    var onBack: () -> Void = {}
    var onComplete: () -> Void = {}

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            switch viewModel.phase {
            case .intro:
                introContent
            case .loading:
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Preparing assessment...").font(KanjiJourneyTheme.bodyLarge)
                }
            case .complete:
                resultContent
            case .question:
                questionContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left"); Text("Back")
                }.foregroundColor(.white)
            }
            ToolbarItem(placement: .principal) {
                Text("Placement Test").font(.headline).foregroundColor(.white)
            }
        }
        .toolbarBackground(KanjiJourneyTheme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { viewModel.configure(container: container) }
    }

    // MARK: - Intro

    private var introContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 32)

                Text("\u{5B66}")
                    .font(.system(size: 80))
                    .foregroundColor(KanjiJourneyTheme.primary)

                Text("Japanese Placement Test")
                    .font(KanjiJourneyTheme.headlineMedium)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 12) {
                    Text("This quick test finds your level so we can personalize your learning. You'll start with hiragana, then katakana, radicals, and kanji \u{2014} each stage getting progressively harder.")
                        .font(KanjiJourneyTheme.bodyLarge)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)

                    Text("Each stage has 5 questions. Score 4 or more to advance. The test ends automatically after 3 minutes or when you don't pass a stage.")
                        .font(KanjiJourneyTheme.bodyLarge)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)

                    Text("Don't worry about getting every answer right \u{2014} the goal is to find where you are so we can start you at the right level.")
                        .font(KanjiJourneyTheme.bodyMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant.opacity(0.8))
                }
                .padding(20)
                .background(KanjiJourneyTheme.surfaceVariant)
                .cornerRadius(16)

                Spacer().frame(height: 16)

                Button {
                    viewModel.beginAssessment()
                } label: {
                    if viewModel.phase == .loading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    } else {
                        Text("Start Test (3 min max)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .background(KanjiJourneyTheme.primary)
                .cornerRadius(12)
                .disabled(viewModel.phase == .loading)
            }
            .padding(24)
        }
    }

    // MARK: - Question

    private var questionContent: some View {
        guard let question = viewModel.currentQuestion else { return AnyView(EmptyView()) }

        return AnyView(ScrollView {
            VStack(spacing: 0) {
                // Timer and progress
                HStack {
                    Text(viewModel.currentStage.displayName)
                        .font(KanjiJourneyTheme.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(KanjiJourneyTheme.primary)

                    Spacer()

                    Text(formatTime(viewModel.timeRemaining))
                        .font(KanjiJourneyTheme.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.timeRemaining <= 30 ? Color(hex: 0xF44336) : KanjiJourneyTheme.onSurfaceVariant)

                    Spacer()

                    Text("\(viewModel.questionIndex + 1) / 5")
                        .font(KanjiJourneyTheme.bodyMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }

                ProgressView(value: Float(viewModel.questionIndex + 1), total: 5)
                    .tint(KanjiJourneyTheme.primary)
                    .padding(.top, 8)

                Spacer().frame(height: 32)

                // Character display card
                VStack(spacing: 8) {
                    KanjiText(text: question.displayCharacter)
                        .font(.system(size: 96))
                    Text(question.prompt)
                        .font(KanjiJourneyTheme.bodyMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(KanjiJourneyTheme.surface)
                .cornerRadius(12)
                .shadow(radius: 4)

                Spacer().frame(height: 24)

                // Answer options
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    answerButton(index: index, option: option, question: question)
                    Spacer().frame(height: 8)
                }

                // Next button
                if viewModel.selectedAnswer != nil {
                    Spacer().frame(height: 16)

                    Button {
                        viewModel.nextQuestion()
                    } label: {
                        Text(viewModel.questionIndex == 4 ? "Finish Stage" : "Next")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(KanjiJourneyTheme.primary)
                            .cornerRadius(12)
                    }

                    Spacer().frame(height: 8)

                    Text("\(viewModel.currentStage.displayName): \(viewModel.stageCorrect) / \(viewModel.questionIndex + 1) correct")
                        .font(KanjiJourneyTheme.bodySmall)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }
            }
            .padding(16)
        })
    }

    private func answerButton(index: Int, option: String, question: PlacementQuestion) -> some View {
        let isSelected = viewModel.selectedAnswer == index
        let isCorrectOption = index == question.correctIndex
        let hasAnswered = viewModel.selectedAnswer != nil

        let borderColor: Color = {
            if !hasAnswered { return KanjiJourneyTheme.onSurfaceVariant.opacity(0.3) }
            if isCorrectOption { return Color(hex: 0x4CAF50) }
            if isSelected { return Color(hex: 0xF44336) }
            return KanjiJourneyTheme.onSurfaceVariant.opacity(0.15)
        }()

        let bgColor: Color = {
            if hasAnswered && isCorrectOption { return Color(hex: 0x4CAF50).opacity(0.1) }
            if hasAnswered && isSelected { return Color(hex: 0xF44336).opacity(0.1) }
            return KanjiJourneyTheme.surface
        }()

        let textColor: Color = {
            if hasAnswered && isCorrectOption { return Color(hex: 0x4CAF50) }
            if hasAnswered && isSelected { return Color(hex: 0xF44336) }
            return KanjiJourneyTheme.onSurface
        }()

        return Button {
            if !hasAnswered { viewModel.selectAnswer(index) }
        } label: {
            Text(option)
                .font(KanjiJourneyTheme.bodyLarge)
                .fontWeight(hasAnswered && isCorrectOption ? .bold : .regular)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(bgColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
    }

    // MARK: - Results

    private var resultContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 16)

                Text(viewModel.timeRemaining <= 0 ? "Time's Up!" : "Assessment Complete!")
                    .font(KanjiJourneyTheme.headlineMedium)
                    .fontWeight(.bold)

                if viewModel.timeRemaining <= 0 {
                    Text("We used your answers so far to find your level.")
                        .font(KanjiJourneyTheme.bodyMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }

                // Level assignment card
                VStack(spacing: 8) {
                    Text("Your Level")
                        .font(KanjiJourneyTheme.titleMedium)
                        .foregroundColor(KanjiJourneyTheme.onSurface)

                    Text("Level \(viewModel.assignedLevel)")
                        .font(KanjiJourneyTheme.headlineLarge)
                        .fontWeight(.bold)
                        .foregroundColor(KanjiJourneyTheme.primary)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(KanjiJourneyTheme.primary.opacity(0.12))
                .cornerRadius(16)

                // Stage breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Results")
                        .font(KanjiJourneyTheme.titleSmall)
                        .fontWeight(.bold)

                    ForEach(Array(viewModel.stageResults.enumerated()), id: \.offset) { _, result in
                        let passed = result.passed
                        HStack {
                            Text(result.stage.displayName)
                                .font(KanjiJourneyTheme.bodyLarge)
                            Spacer()
                            Text("\(result.correct)/\(result.total)")
                                .font(KanjiJourneyTheme.bodyLarge)
                                .fontWeight(.bold)
                                .foregroundColor(passed ? Color(hex: 0x4CAF50) : Color(hex: 0xF44336))
                            Text(passed ? "PASS" : "FAIL")
                                .font(KanjiJourneyTheme.labelSmall)
                                .fontWeight(.bold)
                                .foregroundColor(passed ? Color(hex: 0x4CAF50) : Color(hex: 0xF44336))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(16)
                .background(KanjiJourneyTheme.surface)
                .cornerRadius(KanjiJourneyTheme.radiusM)

                Button {
                    onComplete()
                } label: {
                    Text("Start Learning!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(KanjiJourneyTheme.primary)
                        .cornerRadius(12)
                }

                Text("You can retake this assessment from Settings")
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }
}
