import SwiftUI
import SharedCore

/// HomeView entry point — delegates to HomeViewContent for proper container-based init.
struct HomeView: View {
    @EnvironmentObject var container: AppContainer
    let navigateTo: (NavRoute) -> Void

    var body: some View {
        HomeViewContent(container: container, navigateTo: navigateTo)
    }
}



// MARK: - Subviews

private struct GameModeButtonView: View {
    let label: String
    var subtitle: String? = nil
    var modeColor: Color = GlassBrand.current
    var imageAsset: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassCard(borderColor: modeColor.opacity(0.40)) {
                HStack {
                    if let imageAsset {
                        AssetImage(filename: imageAsset, contentDescription: label)
                            .frame(width: 48, height: 48)
                        Spacer().frame(width: 8)
                    }
                    // Colored accent strip
                    Rectangle()
                        .fill(modeColor)
                        .frame(width: 4)
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(GlassTypography.labelLarge)
                            .foregroundColor(GlassColors.textPrimary)
                        if let subtitle {
                            Text(subtitle)
                                .font(GlassTypography.labelSmall)
                                .foregroundColor(GlassColors.textSecondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct PreviewableGameModeButtonView: View {
    let label: String
    let isPremium: Bool
    let trialInfo: PreviewTrialInfo?
    var modeColor: Color = GlassBrand.current
    var imageAsset: String? = nil
    let onPremiumClick: () -> Void
    let onPreviewClick: () -> Void
    let onUpgradeClick: () -> Void

    var body: some View {
        if isPremium {
            GameModeButtonView(
                label: label, modeColor: modeColor, imageAsset: imageAsset,
                action: onPremiumClick
            )
        } else {
            let remaining = trialInfo?.remaining ?? 0
            let hasTrials = remaining > 0

            Button(action: { hasTrials ? onPreviewClick() : onUpgradeClick() }) {
                GlassCard(borderColor: hasTrials ? modeColor.opacity(0.28) : Color.white.opacity(0.08)) {
                    HStack {
                        if let imageAsset {
                            AssetImage(filename: imageAsset, contentDescription: label)
                                .frame(width: 48, height: 48)
                            Spacer().frame(width: 8)
                        }
                        VStack(alignment: .leading) {
                            Text(label)
                                .font(GlassTypography.labelLarge)
                                .foregroundColor(hasTrials ? GlassColors.textPrimary : GlassColors.textMuted)
                            Text(hasTrials ? "Preview (\(remaining) left)" : "Upgrade to unlock")
                                .font(GlassTypography.labelSmall)
                                .foregroundColor(hasTrials ? GlassColors.textSecondary : KanjiJourneyTheme.coinGold)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct LearningPathCardView: View {
    let title: String
    let subtitle: String
    let progress: Float
    let color: Color

    var body: some View {
        GlassCard(borderColor: color.opacity(0.28)) {
            VStack(spacing: 4) {
                Text(title)
                    .font(GlassTypography.labelMedium)
                    .foregroundColor(GlassColors.textPrimary)
                Text(subtitle)
                    .font(GlassTypography.labelSmall)
                    .foregroundColor(GlassColors.textSecondary)
                ProgressView(value: Double(min(max(progress, 0), 1)))
                    .tint(color)
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 9))
                    .foregroundColor(color)
            }
            .padding(8)
            .frame(width: 100, height: 80)
        }
    }
}

private struct GradeMasteryBadgeView: View {
    let mastery: GradeMastery

    private var badgeAsset: String {
        switch mastery.masteryLevel {
        case .beginning: return "grade-beginning.png"
        case .developing: return "grade-developing.png"
        case .proficient: return "grade-proficient.png"
        case .advanced: return "grade-advanced.png"
        default: return "grade-beginning.png"
        }
    }

    private var ringColor: Color {
        switch mastery.masteryLevel {
        case .beginning: return Color(hex: 0xE57373)
        case .developing: return Color(hex: 0xFFB74D)
        case .proficient: return Color(hex: 0x81C784)
        case .advanced: return Color(hex: 0xFFD700)
        default: return Color(hex: 0xE57373)
        }
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                AssetImage(filename: badgeAsset, contentDescription: "\(mastery.masteryLevel.label) badge")
                    .frame(width: 56, height: 56)
                Text("G\(mastery.grade)")
                    .font(KanjiJourneyTheme.labelLarge)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Text(mastery.masteryLevel.label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(ringColor)
        }
        .padding(4)
    }
}

// MARK: - Grid Items

private struct KanjiGridItemView: View {
    let kanji: Kanji
    var practiceCount: Int32 = 0
    var modeStats: [String: Int32] = [:]
    var collectedItem: CollectedItem? = nil
    let onClick: () -> Void

    var body: some View {
        let isCollected = collectedItem != nil
        let borderColor = collectedItem.map { Color(hex: UInt($0.rarity.colorValue)) }

        ZStack {
            if isCollected {
                KanjiText(text: kanji.literal, font: .system(size: 28))

                // Level badge
                if let item = collectedItem, item.itemLevel > 1 {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Lv.\(item.itemLevel)")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(Color(hex: UInt(item.rarity.colorValue)))
                                .padding(2)
                        }
                        Spacer()
                    }
                }

                // 4-corner mode badges
                let recCount = modeStats["recognition"] ?? 0
                let vocCount = modeStats["vocabulary"] ?? 0
                let wrtCount = modeStats["writing"] ?? 0
                let camCount = modeStats["camera_challenge"] ?? 0

                if recCount > 0 {
                    VStack { HStack { Text("\(recCount)").font(.system(size: 7, weight: .bold)).foregroundColor(Color(hex: 0x2196F3)).padding(3); Spacer() }; Spacer() }
                }
                if vocCount > 0 && (collectedItem?.itemLevel ?? 0) <= 1 {
                    VStack { HStack { Spacer(); Text("\(vocCount)").font(.system(size: 7, weight: .bold)).foregroundColor(Color(hex: 0xFF9800)).padding(3) }; Spacer() }
                }
                if wrtCount > 0 {
                    VStack { Spacer(); HStack { Text("\(wrtCount)").font(.system(size: 7, weight: .bold)).foregroundColor(Color(hex: 0x4CAF50)).padding(3); Spacer() } }
                }
                if camCount > 0 {
                    VStack { Spacer(); HStack { Spacer(); Text("\(camCount)").font(.system(size: 7, weight: .bold)).foregroundColor(Color(hex: 0x9C27B0)).padding(3) } }
                }
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(isCollected ? GlassColors.cardGradient : GlassColors.cardDisabledGradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor ?? GlassColors.border, lineWidth: borderColor != nil ? 2 : 1)
        )
        .onTapGesture { if isCollected { onClick() } }
    }
}

private struct KanaGridItemView: View {
    let kana: Kana
    var collectedItem: CollectedItem? = nil
    let onClick: () -> Void

    var body: some View {
        let isCollected = collectedItem != nil
        let borderColor = collectedItem.map { Color(hex: UInt($0.rarity.colorValue)) }

        ZStack {
            if isCollected {
                VStack(spacing: 0) {
                    Text(kana.literal)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(GlassColors.textPrimary)
                    Text(kana.romanization)
                        .font(.system(size: 8))
                        .foregroundColor(GlassColors.textSecondary)
                }
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(isCollected ? GlassColors.cardGradient : GlassColors.cardDisabledGradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor ?? GlassColors.border, lineWidth: borderColor != nil ? 2 : 1)
        )
        .onTapGesture { if isCollected { onClick() } }
    }
}

private struct RadicalGridItemView: View {
    let radical: Radical
    var collectedItem: CollectedItem? = nil
    let onClick: () -> Void

    var body: some View {
        let isCollected = collectedItem != nil
        let borderColor = collectedItem.map { Color(hex: UInt($0.rarity.colorValue)) }

        ZStack {
            if isCollected {
                VStack(spacing: 2) {
                    RadicalImage(radicalId: radical.id, contentDescription: radical.literal)
                        .frame(width: 36, height: 36)
                    if let meaningJp = radical.meaningJp, !meaningJp.isEmpty {
                        Text(meaningJp)
                            .font(.system(size: 9))
                            .foregroundColor(GlassColors.textPrimary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .background(isCollected ? GlassColors.cardGradient : GlassColors.cardDisabledGradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor ?? GlassColors.border, lineWidth: borderColor != nil ? 2 : 1)
        )
        .onTapGesture { if isCollected { onClick() } }
    }
}

/// Inner view that owns the ViewModel with a proper container reference.
private struct HomeViewContent: View {
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.scenePhase) private var scenePhase
    let navigateTo: (NavRoute) -> Void

    init(container: AppContainer, navigateTo: @escaping (NavRoute) -> Void) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(container: container))
        self.navigateTo = navigateTo
    }

    var body: some View {
        HomeViewBody(viewModel: viewModel, navigateTo: navigateTo)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    viewModel.refresh()
                }
            }
    }
}

/// The actual HomeView body extracted to avoid the init problem.
private struct HomeViewBody: View {
    @ObservedObject var viewModel: HomeViewModel
    let navigateTo: (NavRoute) -> Void

    var body: some View {
        let state = viewModel.uiState

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                profileCard(state: state)

                if !state.isPremium && !state.isAdmin {
                    upgradeBanner
                }

                Spacer().frame(height: 12)
                actionButtonsRow

                if !state.gradeMasteryList.isEmpty {
                    gradeMasterySection(mastery: state.gradeMasteryList)
                }

                Spacer().frame(height: 12)

                if let wotd = state.wordOfTheDay {
                    wordOfTheDayCard(wotd: wotd)
                    Spacer().frame(height: 12)
                }

                learningPathSection(state: state)
                Spacer().frame(height: 12)
                kanaPracticeSection
                Spacer().frame(height: 8)
                radicalModesSection(state: state)
                Spacer().frame(height: 12)
                kanjiStudyModesSection(state: state)
                Spacer().frame(height: 8)
                flashcardCollectionRow(state: state)
                Spacer().frame(height: 16)
                mainTabSelector(state: state)

                if state.selectedMainTab == .kanji {
                    Spacer().frame(height: 4)
                    sortModeTabs(state: state)
                    Spacer().frame(height: 4)
                    filterTabs(state: state)
                }

                sectionTitle(state: state).padding(.top, 4)
                Spacer().frame(height: 8)
                contentGrid(state: state)
                Spacer().frame(height: 16)
            }
            .padding(16)
        }
        .background(GlassColors.background)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 4) {
                    Text("KanjiJourney")
                        .font(GlassTypography.titleSmall)
                        .foregroundColor(GlassColors.textPrimary)
                    if state.isAdmin {
                        Text(state.effectiveLevel.displayName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(adminBadgeColor(level: state.effectiveLevel))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 4) {
                    Button(action: { navigateTo(.shop) }) {
                        Text("J")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(KanjiJourneyTheme.coinGold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(GlassBrand.current.opacity(0.20))
                            .cornerRadius(6)
                    }
                    Button(action: { navigateTo(.settings) }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(GlassColors.textPrimary)
                    }
                }
            }
        }
        .toolbarBackground(GlassColors.surfaceDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // All the same section builders as HomeView above, extracted into this body struct.
    // They reference `viewModel` and `navigateTo` from the struct context.

    private func profileCard(state: HomeUiState) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(state.tierNameJp)
                            .font(GlassTypography.labelMedium)
                            .foregroundColor(GlassBrand.current)
                            .fontWeight(.bold)
                        Text("\(state.tierName) - Lv.\(state.displayLevel)")
                            .font(GlassTypography.titleLarge)
                            .foregroundColor(GlassColors.textPrimary)
                            .fontWeight(.bold)
                        Text("\((state.profile?.totalXp ?? 0)) XP")
                            .font(GlassTypography.bodyMedium)
                            .foregroundColor(KanjiJourneyTheme.coinGold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\((state.coinBalance?.displayBalance ?? 0)) J Coins")
                            .font(GlassTypography.bodyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(KanjiJourneyTheme.coinGold)
                            .onTapGesture { navigateTo(.shop) }
                        if (state.coinBalance?.needsSync ?? false) {
                            Text("Pending sync...")
                                .font(GlassTypography.labelSmall)
                                .foregroundColor(GlassColors.textMuted)
                        }
                        Text("\(state.kanjiCount) kanji loaded")
                            .font(GlassTypography.bodySmall)
                            .foregroundColor(GlassColors.textSecondary)
                    }
                }
                ProgressView(value: Double((state.profile?.xpProgress ?? 0)))
                    .tint(GlassBrand.current)
                if let nextName = state.nextTierName, let nextLevel = state.nextTierLevel {
                    Text("Next: \(nextName) at Lv.\(nextLevel)")
                        .font(GlassTypography.bodySmall)
                        .foregroundColor(GlassColors.textSecondary)
                }
            }
            .padding(16)
        }
    }

    private var upgradeBanner: some View {
        Button(action: { navigateTo(.subscription) }) {
            GlassCard(borderColor: KanjiJourneyTheme.coinGold.opacity(0.40)) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to Premium").font(GlassTypography.labelLarge).fontWeight(.bold).foregroundColor(KanjiJourneyTheme.coinGold)
                        Text("Unlock all modes, J Coins & more").font(GlassTypography.labelSmall).foregroundColor(KanjiJourneyTheme.coinGold.opacity(0.7))
                    }
                    Spacer()
                    Text("$4.99/mo").font(GlassTypography.titleMedium).fontWeight(.bold).foregroundColor(KanjiJourneyTheme.coinGold)
                }
                .padding(12)
            }
        }
        .padding(.top, 8)
    }

    private var actionButtonsRow: some View {
        HStack(spacing: 8) {
            Button(action: { navigateTo(.progress) }) {
                GlassCard(borderColor: KanjiJourneyTheme.secondary.opacity(0.28)) {
                    Text("Progress").font(GlassTypography.labelLarge).foregroundColor(KanjiJourneyTheme.secondary).frame(maxWidth: .infinity).frame(height: 48)
                }
            }
            Button(action: { navigateTo(.achievements) }) {
                GlassCard(borderColor: KanjiJourneyTheme.coinGold.opacity(0.28)) {
                    Text("Achievements").font(GlassTypography.labelLarge).foregroundColor(KanjiJourneyTheme.coinGold).frame(maxWidth: .infinity).frame(height: 48)
                }
            }
        }
    }

    private func gradeMasterySection(mastery: [GradeMastery]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer().frame(height: 12)
            Text("Grade Mastery").font(GlassTypography.titleMedium).foregroundColor(GlassColors.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(mastery, id: \.grade) { m in GradeMasteryBadgeView(mastery: m) }
                }
            }
        }
    }

    private func wordOfTheDayCard(wotd: Vocabulary) -> some View {
        Button(action: { navigateTo(.wordDetail(wordId: wotd.id)) }) {
            GlassCard(borderColor: KanjiJourneyTheme.coinGold.opacity(0.28)) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Word of the Day").font(GlassTypography.labelMedium).foregroundColor(KanjiJourneyTheme.coinGold)
                        Text(wotd.reading).font(GlassTypography.bodySmall).foregroundColor(GlassColors.textSecondary)
                        Text(wotd.primaryMeaning).font(GlassTypography.bodyMedium).foregroundColor(GlassColors.textPrimary)
                    }
                    Spacer()
                    KanjiText(text: wotd.kanjiForm, font: .system(size: 40, weight: .bold))
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }

    private func learningPathSection(state: HomeUiState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Learning Path").font(GlassTypography.titleMedium).foregroundColor(GlassColors.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    LearningPathCardView(title: "Hiragana", subtitle: "ひらがな", progress: state.hiraganaProgress, color: Color(hex: 0xE91E63))
                    LearningPathCardView(title: "Katakana", subtitle: "カタカナ", progress: state.katakanaProgress, color: Color(hex: 0x00BCD4))
                    LearningPathCardView(title: "Radicals", subtitle: "部首", progress: state.radicalProgress, color: Color(hex: 0x795548))
                    ForEach(state.gradeMasteryList, id: \.grade) { m in
                        LearningPathCardView(title: "Grade \(m.grade)", subtitle: "漢字", progress: m.masteryScore, color: KanjiJourneyTheme.primary)
                    }
                }
            }
        }
    }

    private var kanaPracticeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kana Practice").font(GlassTypography.titleMedium).foregroundColor(GlassColors.textPrimary)
            HStack(spacing: 12) {
                GameModeButtonView(label: "Hiragana", subtitle: "Recognition", modeColor: Color(hex: 0xE91E63), imageAsset: "mode-kana-recognition.png", action: { navigateTo(.kanaRecognition(kanaType: "HIRAGANA")) })
                GameModeButtonView(label: "Katakana", subtitle: "Recognition", modeColor: Color(hex: 0x00BCD4), imageAsset: "mode-kana-writing.png", action: { navigateTo(.kanaRecognition(kanaType: "KATAKANA")) })
            }
        }
    }

    private func radicalModesSection(state: HomeUiState) -> some View {
        HStack(spacing: 12) {
            GameModeButtonView(label: "Radicals", subtitle: "Free", modeColor: Color(hex: 0x795548), imageAsset: "mode-radical-recognition.png", action: { navigateTo(.radicalRecognition) })
            PreviewableGameModeButtonView(label: "Radical Builder", isPremium: state.isPremium, trialInfo: state.previewTrials["RADICAL_BUILDER"], modeColor: Color(hex: 0x795548), imageAsset: "mode-radical-builder.png", onPremiumClick: { navigateTo(.radicalBuilder) }, onPreviewClick: { if viewModel.usePreviewTrial(mode: "RADICAL_BUILDER") { navigateTo(.radicalBuilder) } }, onUpgradeClick: { navigateTo(.subscription) })
        }
    }

    private func kanjiStudyModesSection(state: HomeUiState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kanji Study Modes").font(GlassTypography.titleMedium).foregroundColor(GlassColors.textPrimary)
            HStack(spacing: 12) {
                GameModeButtonView(label: "Recognition", subtitle: "Free", modeColor: Color(hex: 0x2196F3), imageAsset: "mode-recognition.png", action: { navigateTo(.recognition) })
                PreviewableGameModeButtonView(label: "Writing", isPremium: state.isPremium, trialInfo: state.previewTrials["WRITING"], modeColor: Color(hex: 0x4CAF50), imageAsset: "mode-writing.png", onPremiumClick: { navigateTo(.writing) }, onPreviewClick: { if viewModel.usePreviewTrial(mode: "WRITING") { navigateTo(.writing) } }, onUpgradeClick: { navigateTo(.subscription) })
            }
            HStack(spacing: 12) {
                PreviewableGameModeButtonView(label: "Vocabulary", isPremium: state.isPremium, trialInfo: state.previewTrials["VOCABULARY"], modeColor: Color(hex: 0xFF9800), imageAsset: "mode-vocabulary.png", onPremiumClick: { navigateTo(.vocabulary) }, onPreviewClick: { if viewModel.usePreviewTrial(mode: "VOCABULARY") { navigateTo(.vocabulary) } }, onUpgradeClick: { navigateTo(.subscription) })
                PreviewableGameModeButtonView(label: "Camera", isPremium: state.isPremium, trialInfo: state.previewTrials["CAMERA_CHALLENGE"], modeColor: Color(hex: 0x9C27B0), imageAsset: "mode-camera.png", onPremiumClick: { navigateTo(.camera) }, onPreviewClick: { if viewModel.usePreviewTrial(mode: "CAMERA_CHALLENGE") { navigateTo(.camera) } }, onUpgradeClick: { navigateTo(.subscription) })
            }
        }
    }

    private func flashcardCollectionRow(state: HomeUiState) -> some View {
        HStack(spacing: 8) {
            Button(action: { navigateTo(.flashcards) }) {
                GlassCard(borderColor: KanjiJourneyTheme.coinGold.opacity(0.28)) {
                    Text(state.flashcardDeckCount > 0 ? "Flashcards (\(state.flashcardDeckCount))" : "Flashcards")
                        .font(GlassTypography.labelLarge).foregroundColor(KanjiJourneyTheme.coinGold).frame(maxWidth: .infinity).frame(height: 48)
                }
            }
            Button(action: { navigateTo(.collection) }) {
                GlassCard(borderColor: Color(hex: 0x9C27B0).opacity(0.40)) {
                    Text("Collection \(state.collectedKanjiCount)/\(state.totalKanjiInGrades)")
                        .font(GlassTypography.labelLarge).foregroundColor(GlassColors.textPrimary).frame(maxWidth: .infinity).frame(height: 48)
                }
            }
        }
    }

    private func mainTabSelector(state: HomeUiState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    let isSelected = tab == state.selectedMainTab
                    GlassChip(selected: isSelected) {
                        Text(tab.rawValue).font(GlassTypography.labelMedium)
                            .foregroundColor(isSelected ? GlassColors.textPrimary : GlassColors.textSecondary)
                    }
                    .onTapGesture { viewModel.selectMainTab(tab) }
                }
            }
        }
    }

    private func sortModeTabs(state: HomeUiState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(KanjiSortMode.allCases, id: \.self) { mode in
                    let isSelected = mode == state.kanjiSortMode
                    GlassChip(selected: isSelected, selectedColor: KanjiJourneyTheme.coinGold) {
                        Text(mode.rawValue).font(GlassTypography.labelSmall)
                            .foregroundColor(isSelected ? GlassColors.textPrimary : GlassColors.textMuted)
                    }
                    .onTapGesture { viewModel.selectSortMode(mode) }
                }
            }
        }
    }

    private func filterTabs(state: HomeUiState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                switch state.kanjiSortMode {
                case .schoolGrade:
                    ForEach(state.allGrades, id: \.self) { grade in
                        let isSelected = grade == state.selectedGrade
                        let hasCollection = state.gradesWithCollection.contains(grade)
                        let collected = state.perGradeCollectedCounts[grade] ?? 0
                        let total = state.perGradeTotalCounts[grade] ?? 0
                        let gradeLabel = grade == 8 ? "G8+" : "G\(grade)"
                        let labelText = total > 0 ? "\(gradeLabel)\n\(collected)/\(total)" : gradeLabel
                        GlassChip(selected: isSelected) {
                            Text(labelText).font(GlassTypography.labelSmall).multilineTextAlignment(.center)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : (hasCollection ? GlassBrand.current : GlassColors.textMuted))
                        }
                        .opacity(hasCollection ? 1.0 : 0.5)
                        .onTapGesture { if hasCollection { viewModel.selectGrade(grade) } }
                    }
                case .jlptLevel:
                    ForEach([5, 4, 3, 2, 1] as [Int32], id: \.self) { level in
                        let isSelected = level == state.selectedJlptLevel
                        let collected = state.perJlptCollectedCounts[level] ?? 0
                        let total = state.perJlptTotalCounts[level] ?? 0
                        let labelText = total > 0 ? "N\(level)\n\(collected)/\(total)" : "N\(level)"
                        GlassChip(selected: isSelected) {
                            Text(labelText).font(GlassTypography.labelSmall).multilineTextAlignment(.center)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : GlassBrand.current)
                        }
                        .onTapGesture { viewModel.selectJlptLevel(level) }
                    }
                case .strokes:
                    ForEach(state.availableStrokeCounts, id: \.self) { count in
                        let isSelected = count == state.selectedStrokeCount
                        GlassChip(selected: isSelected) {
                            Text("\(count)画").font(GlassTypography.labelSmall)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : GlassBrand.current)
                        }
                        .onTapGesture { viewModel.selectStrokeCount(count) }
                    }
                case .frequency:
                    ForEach(Array(HomeViewModel.frequencyLabels.enumerated()), id: \.offset) { index, label in
                        let isSelected = index == state.selectedFrequencyRange
                        GlassChip(selected: isSelected) {
                            Text(label).font(GlassTypography.labelSmall)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : GlassBrand.current)
                        }
                        .onTapGesture { viewModel.selectFrequencyRange(index) }
                    }
                }
            }
        }
    }

    private func sectionTitle(state: HomeUiState) -> some View {
        let title: String
        switch state.selectedMainTab {
        case .hiragana: title = "ひらがな Hiragana"
        case .katakana: title = "カタカナ Katakana"
        case .radicals: title = "部首 Radicals"
        case .kanji:
            switch state.kanjiSortMode {
            case .schoolGrade: title = "Grade \(state.selectedGrade) Kanji"
            case .jlptLevel: title = "JLPT N\(state.selectedJlptLevel) Kanji"
            case .strokes: title = "\(state.selectedStrokeCount)-Stroke Kanji"
            case .frequency: title = "\(HomeViewModel.frequencyLabels[state.selectedFrequencyRange]) Kanji"
            }
        }
        return Text(title).font(GlassTypography.titleMedium).foregroundColor(GlassColors.textPrimary)
    }

    @ViewBuilder
    private func contentGrid(state: HomeUiState) -> some View {
        let columns5 = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
        let columns4 = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

        switch state.selectedMainTab {
        case .hiragana:
            LazyVGrid(columns: columns5, spacing: 8) {
                ForEach(state.hiraganaList, id: \.id) { kana in
                    KanaGridItemView(kana: kana, collectedItem: state.collectedHiraganaItems[kana.id], onClick: { navigateTo(.kanaRecognition(kanaType: "HIRAGANA")) })
                }
            }
        case .katakana:
            LazyVGrid(columns: columns5, spacing: 8) {
                ForEach(state.katakanaList, id: \.id) { kana in
                    KanaGridItemView(kana: kana, collectedItem: state.collectedKatakanaItems[kana.id], onClick: { navigateTo(.kanaRecognition(kanaType: "KATAKANA")) })
                }
            }
        case .radicals:
            LazyVGrid(columns: columns4, spacing: 8) {
                ForEach(state.radicals, id: \.id) { radical in
                    RadicalGridItemView(radical: radical, collectedItem: state.collectedRadicalItems[radical.id], onClick: { navigateTo(.radicalDetail(radicalId: radical.id)) })
                }
            }
        case .kanji:
            LazyVGrid(columns: columns5, spacing: 8) {
                ForEach(state.gradeOneKanji, id: \.id) { kanji in
                    KanjiGridItemView(kanji: kanji, practiceCount: state.kanjiPracticeCounts[kanji.id] ?? 0, modeStats: state.kanjiModeStats[kanji.id] ?? [:], collectedItem: state.collectedItems[kanji.id], onClick: { navigateTo(.kanjiDetail(kanjiId: kanji.id)) })
                }
            }
        }
    }

    private func adminBadgeColor(level: UserLevel) -> Color {
        switch level {
        case .admin: return Color(hex: 0xFF6B6B)
        case .premium: return KanjiJourneyTheme.coinGold
        case .free: return Color.white.opacity(0.7)
        default: return Color.white.opacity(0.7)
        }
    }
}
