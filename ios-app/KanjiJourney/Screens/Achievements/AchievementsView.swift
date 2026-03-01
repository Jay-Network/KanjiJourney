import SwiftUI
import SharedCore

/// Achievements screen. Mirrors Android's AchievementsScreen.kt.
/// Summary card, categorized achievement list with progress.
struct AchievementsView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = AchievementsViewModel()
    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading achievements...").font(KanjiJourneyTheme.bodyLarge)
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Summary card
                        summaryCard

                        // Achievement categories
                        ForEach(viewModel.categories) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.name)
                                    .font(KanjiJourneyTheme.titleLarge)
                                    .fontWeight(.bold)
                                    .padding(.top, 8)

                                ForEach(category.achievements) { achievement in
                                    achievementCard(achievement)
                                }
                            }
                        }
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
                Text("Achievements").font(.headline).foregroundColor(.white)
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

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundColor(KanjiJourneyTheme.xpGold)

            Text("\(viewModel.unlockedCount) / \(viewModel.totalAchievements)")
                .font(KanjiJourneyTheme.headlineMedium)
                .fontWeight(.bold)

            Text("Achievements Unlocked")
                .font(KanjiJourneyTheme.bodyMedium)

            if viewModel.totalAchievements > 0 {
                ProgressView(value: Float(viewModel.unlockedCount), total: Float(viewModel.totalAchievements))
                    .tint(KanjiJourneyTheme.primary)
                let pct = Int(Float(viewModel.unlockedCount) / Float(viewModel.totalAchievements) * 100)
                Text("\(pct)% Complete")
                    .font(KanjiJourneyTheme.bodySmall)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(KanjiJourneyTheme.primary.opacity(0.12))
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }

    // MARK: - Achievement Card

    private func achievementCard(_ achievement: AchievementDefinition) -> some View {
        let isUnlocked = achievement.isUnlocked

        return HStack(spacing: 16) {
            Text(isUnlocked ? achievement.icon : "\u{1F512}")
                .font(.system(size: 36))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(KanjiJourneyTheme.titleMedium)
                    .fontWeight(.bold)
                    .foregroundColor(isUnlocked ? KanjiJourneyTheme.onSurface : KanjiJourneyTheme.onSurfaceVariant.opacity(0.6))

                Text(achievement.description)
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(isUnlocked ? KanjiJourneyTheme.onSurface : KanjiJourneyTheme.onSurfaceVariant.opacity(0.6))

                if !isUnlocked {
                    ProgressView(value: achievement.progressPercent / 100)
                        .tint(KanjiJourneyTheme.primary)
                    Text("\(achievement.progress) / \(achievement.target)")
                        .font(KanjiJourneyTheme.labelSmall)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant.opacity(0.6))
                } else {
                    let dateStr: String = {
                        guard let ts = achievement.unlockedAt else { return "" }
                        let fmt = DateFormatter(); fmt.dateFormat = "MMM dd, yyyy"
                        return fmt.string(from: Date(timeIntervalSince1970: Double(ts)))
                    }()
                    Text("\u{2713} Unlocked \(dateStr)")
                        .font(KanjiJourneyTheme.labelSmall)
                        .fontWeight(.bold)
                        .foregroundColor(KanjiJourneyTheme.primary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isUnlocked ? KanjiJourneyTheme.secondary.opacity(0.12) : KanjiJourneyTheme.surfaceVariant)
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }
}
