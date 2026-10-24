import SwiftUI
import SharedCore

/// Collection hub tab matching Android's CollectionHubScreen.kt.
/// Shows the main tab selector (Hiragana/Katakana/Radicals/Kanji),
/// sort/filter tabs for kanji, and the collection grids.
/// Reuses HomeViewModel like Android does.
struct CollectionHubView: View {
    @EnvironmentObject var container: AppContainer
    let navigateTo: (NavRoute) -> Void

    var body: some View {
        CollectionHubContent(container: container, navigateTo: navigateTo)
    }
}

private struct CollectionHubContent: View {
    @StateObject private var viewModel: HomeViewModel
    let navigateTo: (NavRoute) -> Void

    init(container: AppContainer, navigateTo: @escaping (NavRoute) -> Void) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(container: container))
        self.navigateTo = navigateTo
    }

    var body: some View {
        let state = viewModel.uiState

        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Stats summary
                HStack {
                    Text("\(state.collectedKanjiCount) Collected")
                        .font(GlassTypography.titleLarge)
                        .foregroundColor(GlassColors.textPrimary)
                    Spacer()
                    Text("\(state.collectedKanjiCount)/\(state.totalKanjiInGrades)")
                        .font(GlassTypography.bodySmall)
                        .foregroundColor(GlassColors.textSecondary)
                }
                .padding(.bottom, 4)

                // Quick action buttons
                HStack(spacing: 8) {
                    Button(action: { navigateTo(.flashcards) }) {
                        Text(state.flashcardDeckCount > 0 ? "Flashcards (\(state.flashcardDeckCount))" : "Flashcards")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(KanjiJourneyTheme.onTertiary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(KanjiJourneyTheme.tertiary.opacity(0.2))

                    Button(action: { navigateTo(.collection) }) {
                        Text("Full Collection")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: 0x9C27B0).opacity(0.8))
                }
                .padding(.bottom, 4)

                // Main tab selector
                mainTabSelector(state: state)

                if state.selectedMainTab == .kanji {
                    sortModeTabs(state: state)
                    filterTabs(state: state)
                }

                sectionTitle(state: state)
                    .padding(.top, 4)

                contentGrid(state: state)
            }
            .padding(16)
        }
        .background(GlassColors.background.ignoresSafeArea())
    }

    // MARK: - Tab Selectors (same as HomeView)

    private func mainTabSelector(state: HomeUiState) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    let isSelected = tab == state.selectedMainTab
                    GlassChip(selected: isSelected) {
                        Text(tab.rawValue)
                            .font(GlassTypography.labelMedium)
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
                    Button(action: { viewModel.selectSortMode(mode) }) {
                        GlassChip(selected: isSelected, selectedColor: KanjiJourneyTheme.tertiary) {
                            Text(mode.rawValue)
                                .font(GlassTypography.labelSmall)
                                .foregroundColor(isSelected ? KanjiJourneyTheme.onTertiary : GlassColors.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mode.rawValue)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
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
                            Text(labelText)
                                .font(GlassTypography.labelSmall)
                                .multilineTextAlignment(.center)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : (hasCollection ? GlassColors.textSecondary : GlassColors.textMuted))
                        }
                            .opacity(hasCollection ? 1 : 0.5)
                            .onTapGesture { if hasCollection { viewModel.selectGrade(grade) } }
                    }
                case .kankenLevel:
                    ForEach(HomeViewModel.kankenLevels, id: \.self) { level in
                        let isSelected = level == state.selectedKankenLevel
                        let collected = state.perKankenCollectedCounts[level] ?? 0
                        let total = state.perKankenTotalCounts[level] ?? 0
                        Button(action: { viewModel.selectKankenLevel(level) }) {
                            GlassChip(selected: isSelected) {
                                Text("Level \(level)\n\(collected)/\(total)")
                                    .font(GlassTypography.labelSmall).multilineTextAlignment(.center)
                                    .foregroundColor(isSelected ? GlassColors.textPrimary : GlassColors.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Kanken level \(level), \(collected) of \(total) collected")
                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                    }
                case .jlptLevel:
                    ForEach([5, 4, 3, 2, 1] as [Int32], id: \.self) { level in
                        let isSelected = level == state.selectedJlptLevel
                        let collected = state.perJlptCollectedCounts[level] ?? 0
                        let total = state.perJlptTotalCounts[level] ?? 0
                        let labelText = total > 0 ? "N\(level)\n\(collected)/\(total)" : "N\(level)"
                        GlassChip(selected: isSelected) {
                            Text(labelText)
                                .font(GlassTypography.labelSmall)
                                .multilineTextAlignment(.center)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : GlassColors.textSecondary)
                        }
                            .onTapGesture { viewModel.selectJlptLevel(level) }
                    }
                case .strokes:
                    ForEach(state.availableStrokeCounts, id: \.self) { count in
                        let isSelected = count == state.selectedStrokeCount
                        GlassChip(selected: isSelected) {
                            Text("\(count)画")
                                .font(GlassTypography.labelMedium)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : GlassColors.textSecondary)
                        }
                            .onTapGesture { viewModel.selectStrokeCount(count) }
                    }
                case .frequency:
                    ForEach(Array(HomeViewModel.frequencyLabels.enumerated()), id: \.offset) { index, label in
                        let isSelected = index == state.selectedFrequencyRange
                        GlassChip(selected: isSelected) {
                            Text(label)
                                .font(GlassTypography.labelMedium)
                                .foregroundColor(isSelected ? GlassColors.textPrimary : GlassColors.textSecondary)
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
            case .kankenLevel: title = "Kanken Level \(state.selectedKankenLevel) Kanji"
            case .jlptLevel: title = "JLPT N\(state.selectedJlptLevel) Kanji"
            case .strokes: title = "\(state.selectedStrokeCount)-Stroke Kanji"
            case .frequency: title = "\(HomeViewModel.frequencyLabels[state.selectedFrequencyRange]) Kanji"
            }
        }
        return Text(title)
            .font(GlassTypography.titleMedium)
            .foregroundColor(GlassColors.textPrimary)
    }

    @ViewBuilder
    private func contentGrid(state: HomeUiState) -> some View {
        let columns5 = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
        let columns4 = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

        switch state.selectedMainTab {
        case .hiragana:
            LazyVGrid(columns: columns5, spacing: 8) {
                ForEach(state.hiraganaList, id: \.id) { kana in
                    CollectionKanaGridItem(kana: kana, collectedItem: state.collectedHiraganaItems[kana.id], onClick: { navigateTo(.kanaRecognition(kanaType: "HIRAGANA")) })
                }
            }
        case .katakana:
            LazyVGrid(columns: columns5, spacing: 8) {
                ForEach(state.katakanaList, id: \.id) { kana in
                    CollectionKanaGridItem(kana: kana, collectedItem: state.collectedKatakanaItems[kana.id], onClick: { navigateTo(.kanaRecognition(kanaType: "KATAKANA")) })
                }
            }
        case .radicals:
            LazyVGrid(columns: columns4, spacing: 8) {
                ForEach(state.radicals, id: \.id) { radical in
                    CollectionRadicalGridItem(radical: radical, collectedItem: state.collectedRadicalItems[radical.id], onClick: { navigateTo(.radicalDetail(radicalId: radical.id)) })
                }
            }
        case .kanji:
            LazyVGrid(columns: columns5, spacing: 8) {
                ForEach(state.gradeOneKanji, id: \.id) { kanji in
                    CollectionKanjiGridItem(kanji: kanji, collectedItem: state.collectedItems[kanji.id], onClick: { navigateTo(.kanjiDetail(kanjiId: kanji.id)) })
                }
            }
        }
    }
}

// MARK: - Grid Items (simplified for collection hub)

private struct CollectionKanjiGridItem: View {
    let kanji: Kanji
    var collectedItem: CollectedItem? = nil
    let onClick: () -> Void

    var body: some View {
        let isCollected = collectedItem != nil
        let borderColor = collectedItem.map { Color(hex: UInt($0.rarity.colorValue)) }

        ZStack {
            if isCollected {
                KanjiText(text: kanji.literal, font: .system(size: 28))
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .glassCard(
            cornerRadius: KanjiJourneyTheme.radiusM,
            borderColor: borderColor ?? GlassColors.border,
            borderWidth: borderColor != nil ? 2 : 1
        )
        .opacity(isCollected ? 1 : 0.32)
        .onTapGesture { if isCollected { onClick() } }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { if isCollected { onClick() } }
        .accessibilityHidden(!isCollected)
    }
}

private struct CollectionKanaGridItem: View {
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
                    Text(kana.romanization)
                        .font(.system(size: 8))
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }
            }
        }
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .glassCard(
            cornerRadius: KanjiJourneyTheme.radiusM,
            borderColor: borderColor ?? GlassColors.border,
            borderWidth: borderColor != nil ? 2 : 1
        )
        .opacity(isCollected ? 1 : 0.32)
        .onTapGesture { if isCollected { onClick() } }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { if isCollected { onClick() } }
        .accessibilityHidden(!isCollected)
    }
}

private struct CollectionRadicalGridItem: View {
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
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(height: 72)
        .frame(maxWidth: .infinity)
        .glassCard(
            cornerRadius: KanjiJourneyTheme.radiusM,
            borderColor: borderColor ?? GlassColors.border,
            borderWidth: borderColor != nil ? 2 : 1
        )
        .opacity(isCollected ? 1 : 0.32)
        .onTapGesture { if isCollected { onClick() } }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { if isCollected { onClick() } }
        .accessibilityHidden(!isCollected)
    }
}
