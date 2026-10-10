import SwiftUI
import SharedCore

/// Kanji recognition game screen. Mirrors Android's RecognitionScreen.kt.
/// Shows a kanji and 4 answer choices in a 2x2 grid.
struct RecognitionView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = RecognitionViewModel()
    var targetKanjiId: Int32? = nil
    var onBack: () -> Void = {}

    // Feedback colors tuned for the dark glass background
    private let correctColor = Color(hex: 0x4CAF50)
    private let incorrectColor = Color(hex: 0xFF5252)
    private let discoveryColor = Color(hex: 0x00BFA5)

    var body: some View {
        ZStack {
            GlassColors.background.ignoresSafeArea()

            if let error = viewModel.errorMessage {
                errorContent(error)
            } else if viewModel.sessionComplete {
                sessionCompleteView
            } else if let question = viewModel.currentQuestion {
                questionView(question)
            } else {
                loadingContent
            }

            // Discovery overlay
            if viewModel.showDiscovery, let item = viewModel.discoveredItem {
                DiscoveryOverlay(
                    discoveredItem: item,
                    kanjiLiteral: viewModel.discoveredKanjiLiteral,
                    kanjiMeaning: viewModel.currentQuestion?.kanjiMeaning,
                    onDismiss: { viewModel.showDiscovery = false }
                )
            }
        }
        .foregroundColor(GlassColors.textPrimary)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left"); Text("Back")
                }.foregroundColor(GlassColors.textPrimary)
            }
            ToolbarItem(placement: .principal) {
                Text("Recognition")
                    .font(GlassTypography.titleLarge)
                    .foregroundColor(GlassColors.textPrimary)
            }
        }
        .toolbarBackground(GlassColors.surfaceDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            if viewModel.currentQuestion == nil && !viewModel.sessionComplete {
                viewModel.start(container: container, targetKanjiId: targetKanjiId)
            }
        }
    }

    // MARK: - Loading

    private var loadingContent: some View {
        VStack(spacing: 16) {
            ProgressView().tint(GlassBrand.current)
            Text("Preparing questions...")
                .font(GlassTypography.bodyLarge)
                .foregroundColor(GlassColors.textSecondary)
        }
    }

    // MARK: - Question

    private func questionView(_ question: Question) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Progress bar + stats row
                VStack(spacing: 8) {
                    progressRow
                    ProgressView(value: Float(viewModel.questionNumber), total: Float(viewModel.totalQuestions))
                        .tint(GlassBrand.current)
                        .accessibilityLabel("Question \(viewModel.questionNumber) of \(viewModel.totalQuestions)")
                }
                .padding(12)
                .glassCard()
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer().frame(height: 24)

                // Prompt
                Text("What is the reading?")
                    .font(GlassTypography.titleMedium)
                    .foregroundColor(GlassColors.textSecondary)

                Spacer().frame(height: 16)

                // Large kanji card with NEW badge
                kanjiCard(question)

                Spacer().frame(height: 16)

                // XP popup + readings (shown after answer)
                if viewModel.showResult {
                    resultFeedback(question)
                }

                // 2x2 answer grid
                answerGrid(question)
                    .padding(.horizontal, 16)

                // Next button
                if viewModel.showResult {
                    Spacer().frame(height: 24)
                    primaryButton("Next", height: 48, action: viewModel.next)
                        .padding(.horizontal, 16)
                }

                Spacer().frame(height: 24)
            }
        }
    }

    private var progressRow: some View {
        HStack {
            Text("\(viewModel.questionNumber) / \(viewModel.totalQuestions)")
                .font(GlassTypography.labelLarge)
                .foregroundColor(GlassColors.textSecondary)
            Spacer()
            if viewModel.currentCombo > 1 {
                Text("\(viewModel.currentCombo)x combo")
                    .font(GlassTypography.labelLarge).fontWeight(.bold)
                    .foregroundColor(KanjiJourneyTheme.tertiary)
            }
            Spacer()
            Text("\(viewModel.sessionXp) XP")
                .font(GlassTypography.labelLarge)
                .foregroundColor(GlassBrand.current)
        }
    }

    private func kanjiCard(_ question: Question) -> some View {
        ZStack(alignment: .topTrailing) {
            KanjiText(
                text: question.kanjiLiteral,
                font: .system(size: 96, weight: .regular, design: .serif),
                color: GlassColors.textPrimary
            )
            .frame(width: 200, height: 200)
            .glassCard(cornerRadius: 16, borderColor: GlassColors.borderHover, borderWidth: 1.5)
            .shadow(color: GlassBrand.current.opacity(0.18), radius: 16)

            if question.isNewCard {
                Text("NEW")
                    .font(GlassTypography.labelSmall).fontWeight(.bold)
                    .foregroundColor(GlassColors.textPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(discoveryColor.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(6)
            }
        }
    }

    private func resultFeedback(_ question: Question) -> some View {
        VStack(spacing: 4) {
            if let correct = viewModel.isCorrect {
                Text(correct ? "+\(viewModel.xpGained) XP" : "Incorrect")
                    .font(GlassTypography.titleLarge).fontWeight(.bold)
                    .foregroundColor(correct ? KanjiJourneyTheme.tertiary : incorrectColor)
                    .transition(.scale.combined(with: .opacity))
            }

            if let meaning = question.kanjiMeaning, !meaning.isEmpty {
                Text(meaning)
                    .font(GlassTypography.titleMedium)
                    .foregroundColor(GlassColors.textPrimary)
            }

            let kunReadings = question.kunReadings as? [String] ?? []
            if !kunReadings.isEmpty {
                KanjiText(
                    text: "訓: \(kunReadings.joined(separator: "、"))",
                    font: GlassTypography.bodyLarge,
                    fontWeight: .bold,
                    color: GlassBrand.current
                )
            }

            let onReadings = question.onReadings as? [String] ?? []
            if !onReadings.isEmpty {
                KanjiText(
                    text: "音: \(onReadings.joined(separator: "、"))",
                    font: GlassTypography.bodyMedium,
                    color: GlassColors.textSecondary
                )
            }

            let words = question.exampleWords as? [Vocabulary] ?? []
            if !words.isEmpty {
                ForEach(Array(words.prefix(3).enumerated()), id: \.offset) { _, vocab in
                    KanjiText(
                        text: "\(vocab.kanjiForm) (\(vocab.reading)) \(vocab.primaryMeaning)",
                        font: GlassTypography.bodySmall,
                        color: GlassColors.textSecondary
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .glassCard()
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func answerGrid(_ question: Question) -> some View {
        let choices = question.choices
        return VStack(spacing: 12) {
            ForEach(0..<(choices.count + 1) / 2, id: \.self) { rowIndex in
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { colIndex in
                        let index = rowIndex * 2 + colIndex
                        if index < choices.count {
                            answerButton(choices[index], question: question)
                        }
                    }
                }
            }
        }
    }

    private func answerButton(_ choice: String, question: Question) -> some View {
        let isSelected = viewModel.selectedAnswer == choice
        let isAnswer = choice == question.correctAnswer
        let showing = viewModel.showResult

        // Before answering: neutral glass with brand border.
        // After: green = correct answer, red = wrong pick, others dimmed.
        let tint: Color? = {
            guard showing else { return nil }
            if isAnswer { return correctColor }
            if isSelected { return incorrectColor }
            return nil
        }()
        let dimmed = showing && tint == nil

        return Button {
            if !viewModel.showResult {
                viewModel.submitAnswer(choice)
            }
        } label: {
            KanjiText(text: choice, font: .system(size: 20), color: GlassColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(tint?.opacity(0.30) ?? Color.clear)
                .glassCard(
                    borderColor: tint ?? GlassColors.borderHover,
                    borderWidth: tint == nil ? 1 : 2
                )
                .opacity(dimmed ? 0.5 : 1.0)
                .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.showResult)
        .accessibilityLabel(answerAccessibilityLabel(choice, isAnswer: isAnswer, isSelected: isSelected))
    }

    private func answerAccessibilityLabel(_ choice: String, isAnswer: Bool, isSelected: Bool) -> String {
        guard viewModel.showResult else { return choice }
        if isAnswer { return "\(choice), correct answer" }
        if isSelected { return "\(choice), your answer, incorrect" }
        return choice
    }

    // MARK: - Session Complete

    private var sessionCompleteView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 32)

                Text("Session Complete!")
                    .font(GlassTypography.headlineMedium).fontWeight(.bold)

                // Stats card
                VStack(spacing: 12) {
                    statRow("Cards Studied", "\(viewModel.questionNumber)")
                    statRow("Correct", "\(viewModel.correctCount) / \(viewModel.questionNumber)")
                    statRow("Accuracy", "\(viewModel.questionNumber > 0 ? viewModel.correctCount * 100 / viewModel.questionNumber : 0)%")
                    statRow("Best Combo", "\(viewModel.comboMax)x")
                    statRow("XP Earned", "+\(viewModel.sessionXp)")
                    statRow("Duration", formatDuration(viewModel.durationSec))
                }
                .padding(20)
                .glassCard()
                .padding(.horizontal, 16)

                // New discoveries
                if !viewModel.newDiscoveries.isEmpty {
                    VStack(spacing: 8) {
                        Text("New Discoveries")
                            .font(GlassTypography.titleMedium).fontWeight(.bold)
                            .foregroundColor(discoveryColor)

                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.newDiscoveries.enumerated()), id: \.offset) { _, discovery in
                                VStack {
                                    KanjiText(
                                        text: discovery.literal,
                                        font: .system(size: 36, design: .serif),
                                        color: GlassColors.textPrimary
                                    )
                                    Text(discovery.meaning)
                                        .font(GlassTypography.bodySmall)
                                        .foregroundColor(GlassColors.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(discoveryColor.opacity(0.10))
                    .glassCard(borderColor: discoveryColor.opacity(0.45))
                    .padding(.horizontal, 16)
                }

                primaryButton("Done", height: 56) {
                    viewModel.reset()
                    onBack()
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
    }

    // MARK: - Error

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(GlassBrand.current)
                .accessibilityHidden(true)
            Text(message)
                .font(GlassTypography.bodyLarge)
                .multilineTextAlignment(.center)
            Button(action: onBack) {
                Text("Go Back")
                    .font(GlassTypography.labelLarge)
                    .foregroundColor(GlassColors.textPrimary)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 44)
                    .glassCard(borderColor: GlassColors.borderHover)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .glassCard()
        .padding(24)
    }

    // MARK: - Helpers

    private func primaryButton(_ title: String, height: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(GlassTypography.labelLarge).fontWeight(.bold)
                .foregroundColor(GlassColors.textPrimary)
                .frame(maxWidth: .infinity).frame(height: height)
                .background(GlassBrand.current.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(GlassBrand.current, lineWidth: 1)
                )
                .shadow(color: GlassBrand.current.opacity(0.35), radius: 10)
                .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(GlassTypography.bodyLarge)
                .foregroundColor(GlassColors.textSecondary)
            Spacer()
            Text(value)
                .font(GlassTypography.bodyLarge).fontWeight(.bold)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}
