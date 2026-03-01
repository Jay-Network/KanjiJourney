import SwiftUI
import SharedCore

/// Progress & Stats screen. Mirrors Android's ProgressScreen.kt.
/// Level/XP, Streak, Kanji Mastery, Grade Breakdown, Overall Stats, Recent Sessions.
struct KQProgressView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = ProgressViewModel()
    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading your stats...").font(KanjiJourneyTheme.bodyLarge)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        levelCard
                        streakCard
                        kanjiMasteryCard
                        if !viewModel.gradeMasteryList.isEmpty { gradeMasteryBreakdownCard }
                        overallStatsCard
                        if !viewModel.recentSessions.isEmpty { recentSessionsCard }
                    }
                    .padding(16)
                }
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
                Text("Progress & Stats").font(.headline).foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.refresh(container: container) }) {
                    Image(systemName: "arrow.clockwise")
                }.foregroundColor(.white)
            }
        }
        .toolbarBackground(KanjiJourneyTheme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { viewModel.load(container: container) }
    }

    // MARK: - Level & XP

    private var levelCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Level \(viewModel.level)")
                .font(KanjiJourneyTheme.headlineMedium).fontWeight(.bold)
            Text("\(viewModel.totalXp) XP")
                .font(KanjiJourneyTheme.titleLarge)
            Text("Progress to Level \(viewModel.level + 1)")
                .font(KanjiJourneyTheme.bodyMedium)
            ProgressView(value: viewModel.xpProgress).tint(KanjiJourneyTheme.primary)
            Text("\(viewModel.xpInCurrentLevel) / \(viewModel.xpForNextLevel) XP")
                .font(KanjiJourneyTheme.bodySmall)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.primary.opacity(0.12))
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }

    // MARK: - Streak

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Streak").font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
            HStack(spacing: 0) {
                statItem(icon: "flame.fill", value: "\(viewModel.currentStreak) days", label: "Current")
                statItem(icon: "star.fill", value: "\(viewModel.longestStreak) days", label: "Longest")
                statItem(icon: "target", value: "\(viewModel.dailyGoal) XP", label: "Daily Goal")
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.secondary.opacity(0.12))
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }

    // MARK: - Kanji Mastery

    private var kanjiMasteryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kanji Mastery").font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
            HStack(spacing: 0) {
                statItem(icon: "checkmark.circle.fill", value: "\(viewModel.masteredCount)", label: "Mastered")
                statItem(icon: "book.fill", value: "\(viewModel.totalKanjiInSrs - viewModel.masteredCount)", label: "In Progress")
                statItem(icon: "character.ja", value: "\(viewModel.totalKanjiInSrs)", label: "Total")
            }
            if viewModel.totalKanjiInSrs > 0 {
                let pct = Int(Float(viewModel.masteredCount) / Float(viewModel.totalKanjiInSrs) * 100)
                ProgressView(value: Float(viewModel.masteredCount), total: Float(viewModel.totalKanjiInSrs))
                    .tint(KanjiJourneyTheme.tertiary)
                Text("\(pct)% Mastery Rate").font(KanjiJourneyTheme.bodySmall)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.tertiary.opacity(0.12))
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }

    // MARK: - Grade Mastery Breakdown

    private var gradeMasteryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Grade Mastery").font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
            ForEach(viewModel.gradeMasteryList, id: \.grade) { mastery in
                gradeMasteryRow(mastery)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.surface).cornerRadius(KanjiJourneyTheme.radiusM)
    }

    private func gradeMasteryRow(_ mastery: GradeMastery) -> some View {
        let color = masteryColor(mastery.masteryLevel)
        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.2)).frame(width: 40, height: 40)
                Text("G\(mastery.grade)").font(KanjiJourneyTheme.labelMedium).fontWeight(.bold).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Grade \(mastery.grade)").font(KanjiJourneyTheme.bodyMedium).fontWeight(.bold)
                    Spacer()
                    Text(mastery.masteryLevel.label).font(KanjiJourneyTheme.labelMedium).fontWeight(.bold).foregroundColor(color)
                }
                ProgressView(value: mastery.coverage).tint(color)
                HStack {
                    Text("\(mastery.studiedCount)/\(mastery.totalKanjiInGrade) studied")
                    Spacer()
                    Text("\(mastery.masteredCount) mastered")
                    Spacer()
                    Text("\(Int(mastery.averageAccuracy * 100))% acc")
                }.font(KanjiJourneyTheme.bodySmall).foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            }
        }
    }

    private func masteryColor(_ level: MasteryLevel) -> Color {
        switch level {
        case .beginning: return Color(hex: 0xE57373)
        case .developing: return Color(hex: 0xFFB74D)
        case .proficient: return Color(hex: 0x81C784)
        case .advanced: return Color(hex: 0xFFD700)
        default: return .gray
        }
    }

    // MARK: - Overall Stats

    private var overallStatsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overall Statistics").font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
            HStack(spacing: 0) {
                statItem(icon: "gamecontroller.fill", value: "\(viewModel.totalGamesPlayed)", label: "Games")
                statItem(icon: "square.and.pencil", value: "\(viewModel.totalCardsStudied)", label: "Cards")
                statItem(icon: "target", value: "\(Int(viewModel.overallAccuracy))%", label: "Accuracy")
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.surface).cornerRadius(KanjiJourneyTheme.radiusM)
    }

    // MARK: - Recent Sessions

    private var recentSessionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions").font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
            ForEach(viewModel.recentSessions.prefix(5), id: \.startedAt) { session in
                sessionRow(session)
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.surfaceVariant).cornerRadius(KanjiJourneyTheme.radiusM)
    }

    private func sessionRow(_ session: StudySession) -> some View {
        let accuracy = session.cardsStudied > 0
            ? Int(Float(session.correctCount) / Float(session.cardsStudied) * 100) : 0
        let date = Date(timeIntervalSince1970: Double(session.startedAt))
        let fmt = DateFormatter(); fmt.dateFormat = "MMM dd, HH:mm"
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.gameMode.uppercased()).font(KanjiJourneyTheme.bodyMedium).fontWeight(.bold)
                Text(fmt.string(from: date)).font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant.opacity(0.7))
            }
            Spacer()
            Text("\(session.cardsStudied) cards").font(KanjiJourneyTheme.bodySmall)
            Text("\(accuracy)%").font(KanjiJourneyTheme.bodyMedium).fontWeight(.bold)
                .foregroundColor(accuracy >= 80 ? KanjiJourneyTheme.primary : accuracy >= 60 ? KanjiJourneyTheme.secondary : KanjiJourneyTheme.error)
            Text("+\(session.xpEarned) XP").font(KanjiJourneyTheme.bodyMedium).fontWeight(.bold)
                .foregroundColor(KanjiJourneyTheme.tertiary)
        }.padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.title2).foregroundColor(KanjiJourneyTheme.primary)
            Text(value).font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
            Text(label).font(KanjiJourneyTheme.bodySmall).foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }
}
