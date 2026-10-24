import SwiftUI
import SharedCore

/// Collection screen. Mirrors Android's CollectionScreen.kt.
/// Tabs for item types, rarity filters, grid display with stats.
struct CollectionView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = CollectionViewModel()
    var onBack: () -> Void = {}
    var onKanjiClick: ((Int32) -> Void)? = nil

    var body: some View {
        ZStack {
            GlassColors.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView().tint(GlassBrand.current)
                    Text("Loading collection...")
                        .font(GlassTypography.bodyLarge)
                        .foregroundColor(GlassColors.textSecondary)
                }
            } else {
                VStack(spacing: 0) {
                    // Stats summary
                    HStack(spacing: 12) {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(GlassBrand.current)
                            .accessibilityHidden(true)
                        Text("\(viewModel.totalCollected) Collected")
                            .font(GlassTypography.titleLarge)
                        Spacer()
                    }
                    .padding(16)
                    .glassCard()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    // Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(CollectionTab.allCases, id: \.self) { tab in
                                let selected = viewModel.selectedTab == tab
                                Button { viewModel.selectTab(tab) } label: {
                                    GlassChip(selected: selected) {
                                        Text(tab.rawValue)
                                            .font(GlassTypography.labelLarge)
                                            .foregroundColor(selected ? GlassColors.textPrimary : GlassColors.textSecondary)
                                    }
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(selected ? [.isSelected] : [])
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Rarity filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            rarityChip(nil, label: "All")
                            ForEach([CollectedItemRarity.common, .uncommon, .rare, .epic, .legendary], id: \.self) { rarity in
                                rarityChip(rarity, label: rarity.label)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 6)
                    }

                    // Grid
                    ScrollView {
                        if viewModel.filteredItems.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(GlassBrand.current)
                                    .accessibilityHidden(true)
                                Text(viewModel.selectedRarityFilter == nil ? "No items collected yet" : "No items match this rarity")
                                    .font(GlassTypography.titleMedium)
                                Text(viewModel.selectedRarityFilter == nil ? "Practice to grow your collection." : "Choose another rarity or All to see more items.")
                                    .font(GlassTypography.bodyMedium)
                                    .foregroundColor(GlassColors.textSecondary)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .glassCard()
                            .padding(16)
                            .accessibilityElement(children: .combine)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 8)], spacing: 8) {
                                ForEach(viewModel.filteredItems, id: \.itemId) { item in
                                    collectionItemCard(item)
                                }
                            }
                            .padding(12)
                        }
                    }
                }
            }
        }
        .foregroundColor(GlassColors.textPrimary)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left").accessibilityHidden(true); Text("Back")
                }.foregroundColor(GlassColors.textPrimary)
            }
            ToolbarItem(placement: .principal) {
                Text("Collection")
                    .font(GlassTypography.titleLarge)
                    .foregroundColor(GlassColors.textPrimary)
            }
        }
        .toolbarBackground(GlassColors.surfaceDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { viewModel.load(container: container) }
    }

    private func rarityChip(_ rarity: CollectedItemRarity?, label: String) -> some View {
        let selected = viewModel.selectedRarityFilter == rarity
        let tint = rarity.map { Color(hex: UInt($0.colorValue)) } ?? GlassBrand.current
        return Button { viewModel.filterByRarity(rarity) } label: {
            GlassChip(selected: selected, selectedColor: tint) {
                Text(label)
                    .font(GlassTypography.labelMedium)
                    .foregroundColor(selected ? GlassColors.textPrimary : GlassColors.textSecondary)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private func collectionItemCard(_ item: CollectedItem) -> some View {
        let rarityColor = Color(hex: UInt(item.rarity.colorValue))
        let literal = viewModel.kanjiLiterals["\(item.itemId)"] ?? "\(item.itemId)"

        return Button {
            if viewModel.selectedTab == .kanji {
                onKanjiClick?(item.itemId)
            }
        } label: {
            Text(literal)
                .font(.system(size: 28))
                .foregroundColor(GlassColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .glassCard(borderColor: rarityColor, borderWidth: 2)
                .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(literal), \(item.rarity.label)")
    }
}
