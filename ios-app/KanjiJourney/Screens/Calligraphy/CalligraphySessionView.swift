import SwiftUI
import SharedCore

struct CalligraphySessionView: View {
    @EnvironmentObject var container: AppContainer
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CalligraphySessionViewModel()

    let kanjiLiteral: String
    let strokePaths: [String]

    @State private var strokes: [[CalligraphyPointData]] = []
    @State private var activeStroke: [CalligraphyPointData] = []
    @State private var canvasVersion = 0

    /// Warm paper color matching the canvas
    private let paperBackground = Color(red: 1.0, green: 0.973, blue: 0.941)

    var body: some View {
        VStack(spacing: 0) {
            // Header: kanji + stroke count
            headerSection

            // Canvas
            canvasSection

            // Controls
            controlsSection

            // Result / Feedback
            if viewModel.showResult {
                ScrollView {
                    resultSection
                }
            }
        }
        .overlay {
            if viewModel.sessionComplete, let stats = viewModel.sessionStats {
                sessionCompleteOverlay(stats: stats)
            }
        }
        .background(paperBackground)
        .navigationTitle("書道")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.setup(container: container, kanji: kanjiLiteral, strokePaths: strokePaths)
            await viewModel.startSession()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            Text(viewModel.currentKanji)
                .font(KanjiJourneyTheme.kanjiMedium)
                .foregroundColor(KanjiJourneyTheme.primary)

            VStack(alignment: .leading) {
                Text("Strokes: \(viewModel.currentStrokePaths.count)")
                    .font(KanjiJourneyTheme.labelLarge)
                Text("Drawn: \(strokes.count)")
                    .font(KanjiJourneyTheme.labelSmall)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if viewModel.isAILoading {
                SwiftUI.ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .padding()
    }

    private var canvasSection: some View {
        CalligraphyCanvasView(
            strokes: $strokes,
            activeStroke: $activeStroke,
            referenceStrokePaths: viewModel.currentStrokePaths,
            canvasVersion: canvasVersion,
            onStrokeComplete: { _ in
                // Auto-submit when stroke count matches
                if strokes.count == viewModel.currentStrokePaths.count {
                    Task {
                        await viewModel.submitDrawing(strokes: strokes)
                    }
                }
            }
        )
        .aspectRatio(1.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: KanjiJourneyTheme.radiusM))
        .overlay(
            RoundedRectangle(cornerRadius: KanjiJourneyTheme.radiusM)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    viewModel.updateCanvasSize(geo.size)
                }
            }
        )
        .padding(.horizontal)
    }

    private var controlsSection: some View {
        HStack(spacing: KanjiJourneyTheme.spacingM) {
            Button("Clear") {
                strokes = []
                activeStroke = []
                canvasVersion += 1
                viewModel.reset()
            }
            .buttonStyle(.bordered)

            Button("Undo") {
                if !strokes.isEmpty {
                    strokes.removeLast()
                    viewModel.reset()
                }
            }
            .buttonStyle(.bordered)
            .disabled(strokes.isEmpty)

            Spacer()

            Button("Submit") {
                Task {
                    await viewModel.submitDrawing(strokes: strokes)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(KanjiJourneyTheme.primary)
            .disabled(strokes.isEmpty)
        }
        .padding()
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: KanjiJourneyTheme.spacingS) {
            // Score header
            HStack {
                Text("Score")
                    .font(KanjiJourneyTheme.labelLarge)
                Spacer()
                Text(viewModel.isCorrect ? "Correct" : "Try Again")
                    .font(KanjiJourneyTheme.labelLarge)
                    .foregroundColor(viewModel.isCorrect ? KanjiJourneyTheme.success : KanjiJourneyTheme.error)

                Text("Quality: \(viewModel.quality)/5")
                    .font(KanjiJourneyTheme.labelSmall)
                    .foregroundColor(.secondary)
            }

            if let xp = viewModel.xpGained {
                Text("+\(xp) XP")
                    .font(KanjiJourneyTheme.labelLarge)
                    .foregroundColor(KanjiJourneyTheme.xpGold)
            }

            // AI Calligraphy Feedback
            if let feedback = viewModel.calligraphyFeedback {
                Divider()

                Text("AI 書道 Feedback")
                    .font(KanjiJourneyTheme.labelLarge)

                if !feedback.overallComment.isEmpty {
                    Text(feedback.overallComment)
                        .font(KanjiJourneyTheme.bodyMedium)
                }

                // Stroke ending scores
                strokeEndingScoresView(feedback: feedback)

                // Pressure feedback
                if !feedback.pressureFeedback.isEmpty {
                    HStack(alignment: .top) {
                        Text("筆圧:")
                            .font(KanjiJourneyTheme.labelSmall)
                            .foregroundColor(KanjiJourneyTheme.primary)
                        Text(feedback.pressureFeedback)
                            .font(KanjiJourneyTheme.bodyMedium)
                    }
                }

                // Movement feedback
                if !feedback.movementFeedback.isEmpty {
                    HStack(alignment: .top) {
                        Text("運筆:")
                            .font(KanjiJourneyTheme.labelSmall)
                            .foregroundColor(KanjiJourneyTheme.primary)
                        Text(feedback.movementFeedback)
                            .font(KanjiJourneyTheme.bodyMedium)
                    }
                }

                // Per-stroke feedback
                ForEach(Array(feedback.strokeFeedback.enumerated()), id: \.offset) { _, tip in
                    Text("• \(tip)")
                        .font(KanjiJourneyTheme.bodyMedium)
                        .foregroundColor(.secondary)
                }
            }

            // Next button
            Button("Next Kanji") {
                strokes = []
                activeStroke = []
                canvasVersion += 1
                Task {
                    await viewModel.nextKanji()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(KanjiJourneyTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.top, KanjiJourneyTheme.spacingS)
        }
        .padding()
        .background(KanjiJourneyTheme.surfaceVariant)
        .cornerRadius(KanjiJourneyTheme.radiusM)
        .padding(.horizontal)
    }

    // MARK: - Stroke Ending Scores

    /// Maps technique labels to their badge image asset names
    private static let techniqueBadgeMap: [String: String] = [
        "Tome": "Calligraphy/BadgeTome",
        "Hane": "Calligraphy/BadgeHane",
        "Harai": "Calligraphy/BadgeHarai",
    ]

    @ViewBuilder
    private func strokeEndingScoresView(feedback: CalligraphyFeedbackService.CalligraphyFeedback) -> some View {
        let hasAnyScore = feedback.tomeScore != nil || feedback.haneScore != nil
            || feedback.haraiScore != nil || feedback.balanceScore != nil

        if hasAnyScore {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    if let balance = feedback.balanceScore {
                        scoreChip(label: "Balance", kanji: "均", score: balance)
                    }
                    if let tome = feedback.tomeScore {
                        scoreChip(label: "Tome", kanji: "止", score: tome)
                    }
                    if let hane = feedback.haneScore {
                        scoreChip(label: "Hane", kanji: "撥", score: hane)
                    }
                    if let harai = feedback.haraiScore {
                        scoreChip(label: "Harai", kanji: "払", score: harai)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func scoreChip(label: String, kanji: String, score: Int) -> some View {
        VStack(spacing: 2) {
            // Show badge image for technique chips (tome/hane/harai)
            if let badgeName = Self.techniqueBadgeMap[label] {
                Image(badgeName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            Text(kanji)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(scoreColor(score))
            HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { i in
                    Circle()
                        .fill(i <= score ? scoreColor(score) : Color.gray.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 50)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(scoreColor(score).opacity(0.08))
        .cornerRadius(8)
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 5: return .green
        case 4: return Color(red: 0.2, green: 0.7, blue: 0.3)
        case 3: return .orange
        case 2: return Color(red: 0.9, green: 0.5, blue: 0.2)
        default: return .red
        }
    }

    // MARK: - Session Complete Overlay

    private func sessionCompleteOverlay(stats: SessionStats) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: KanjiJourneyTheme.spacingL) {
                Text("Session Complete!")
                    .font(KanjiJourneyTheme.titleLarge)
                    .foregroundColor(.white)

                // Mastery grade badge (if available)
                if let mastery = viewModel.currentGradeMastery {
                    MasteryBadgeView(level: mastery.masteryLevel, size: 80)
                }

                VStack(spacing: KanjiJourneyTheme.spacingS) {
                    statRow(label: "Kanji Studied", value: "\(stats.cardsStudied)")
                    statRow(label: "Correct", value: "\(stats.correctCount)/\(stats.cardsStudied)")
                    statRow(label: "Best Combo", value: "\(stats.comboMax)")
                    statRow(label: "XP Earned", value: "+\(stats.xpEarned)")
                    statRow(label: "Duration", value: "\(stats.durationSec)s")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(KanjiJourneyTheme.radiusL)

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(KanjiJourneyTheme.primary)
            }
            .padding(KanjiJourneyTheme.spacingXL)
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(KanjiJourneyTheme.bodyMedium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(KanjiJourneyTheme.labelLarge)
                .foregroundColor(.primary)
        }
    }
}
