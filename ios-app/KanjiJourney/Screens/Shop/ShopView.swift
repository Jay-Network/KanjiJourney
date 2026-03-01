import SwiftUI
import SharedCore

/// Shop screen. Mirrors Android's ShopScreen.kt.
/// J Coin shop with featured banner, category filters, item grid, purchase dialog.
struct ShopView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = ShopViewModel()
    var onBack: () -> Void = {}

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading shop...").font(KanjiJourneyTheme.bodyLarge)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        if let featured = viewModel.featuredItem {
                            featuredBanner(featured)
                        }

                        categoryFilterRow

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.filteredItems, id: \.id) { item in
                                let isOwned = item.contentId != nil && viewModel.ownedContentIds.contains(item.contentId ?? "")
                                shopItemCard(item, isOwned: isOwned)
                            }
                        }
                        .padding(12)
                    }
                }
            }

            // Purchase dialog overlay
            if let item = viewModel.purchaseDialogItem {
                purchaseOverlay(item)
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
                HStack(spacing: 12) {
                    Text("J Coin Shop").font(.headline).foregroundColor(.white)
                    Text("\(viewModel.balance) coins")
                        .font(KanjiJourneyTheme.bodyMedium)
                        .fontWeight(.bold)
                        .foregroundColor(KanjiJourneyTheme.xpGold)
                }
            }
        }
        .toolbarBackground(KanjiJourneyTheme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { viewModel.load(container: container) }
    }

    // MARK: - Featured Banner

    private func featuredBanner(_ item: ShopItem) -> some View {
        let canAfford = viewModel.balance >= item.cost

        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TutoringJay")
                    .font(KanjiJourneyTheme.labelMedium)
                    .foregroundColor(.white.opacity(0.8))
                Text("Free 30-min Japanese Lesson")
                    .font(KanjiJourneyTheme.titleMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Earn coins playing KanjiJourney, redeem for a real tutoring session!")
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            VStack(spacing: 6) {
                if viewModel.hasRedeemedTrial {
                    Circle()
                        .fill(Color(hex: 0x4CAF50))
                        .frame(width: 36, height: 36)
                        .overlay(Text("\u{2713}").foregroundColor(.white).fontWeight(.bold))
                    Button("Book Now") { openTutoringJayBooking() }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: 0xE65100))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.white)
                        .cornerRadius(20)
                } else {
                    Text("\(item.cost)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(canAfford ? KanjiJourneyTheme.xpGold : Color(hex: 0xFF8A80))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(12)
                    Button("Redeem") { viewModel.purchaseFeatured() }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(canAfford ? Color(hex: 0xE65100) : .white.opacity(0.6))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(canAfford ? .white : .white.opacity(0.4))
                        .cornerRadius(20)
                        .disabled(!canAfford)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(hex: 0xE65100), Color(hex: 0xFF8F00)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .padding(12)
    }

    // MARK: - Category Filter

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton("All", isSelected: viewModel.selectedCategory == nil) {
                    viewModel.selectCategory(nil)
                }
                ForEach(viewModel.categories, id: \.self) { category in
                    chipButton(category.name, isSelected: viewModel.selectedCategory == category) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private func chipButton(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(KanjiJourneyTheme.bodySmall)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? .white : KanjiJourneyTheme.primary)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(isSelected ? KanjiJourneyTheme.primary : KanjiJourneyTheme.surfaceVariant)
                .cornerRadius(16)
        }
    }

    // MARK: - Shop Item Card

    private func shopItemCard(_ item: ShopItem, isOwned: Bool) -> some View {
        let canAfford = viewModel.balance >= item.cost

        return Button {
            if !isOwned { viewModel.showPurchaseDialog(item) }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                AssetImage(filename: categoryImageAsset(item.category), contentDescription: item.category.name)
                    .frame(width: 40, height: 40)

                Text(item.name)
                    .font(KanjiJourneyTheme.titleSmall)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundColor(KanjiJourneyTheme.onSurface)

                Text(item.description_)
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    .lineLimit(2)

                if isOwned {
                    Text("Owned")
                        .font(KanjiJourneyTheme.labelMedium)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: 0x4CAF50))
                } else {
                    Text("\(item.cost) coins")
                        .font(KanjiJourneyTheme.labelMedium)
                        .fontWeight(.bold)
                        .foregroundColor(canAfford ? KanjiJourneyTheme.xpGold : KanjiJourneyTheme.error)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isOwned ? KanjiJourneyTheme.surfaceVariant : KanjiJourneyTheme.surface)
            .cornerRadius(12)
        }
        .disabled(isOwned)
    }

    // MARK: - Purchase Dialog Overlay

    private func purchaseOverlay(_ item: ShopItem) -> some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { viewModel.dismissPurchaseDialog() }

            VStack(spacing: 16) {
                if viewModel.purchaseResult == nil {
                    Text("Confirm Purchase")
                        .font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
                    Text("Buy \(item.name) for \(item.cost) coins?")
                    Text("Your balance: \(viewModel.balance) coins")
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    if viewModel.balance < item.cost {
                        Text("Insufficient funds")
                            .font(KanjiJourneyTheme.bodySmall)
                            .foregroundColor(KanjiJourneyTheme.error)
                    }
                    HStack(spacing: 12) {
                        Button("Cancel") { viewModel.dismissPurchaseDialog() }
                            .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                        Button("Buy (\(item.cost))") { viewModel.confirmPurchase(item) }
                            .fontWeight(.bold).foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(viewModel.balance >= item.cost ? KanjiJourneyTheme.primary : Color.gray)
                            .cornerRadius(8)
                            .disabled(viewModel.balance < item.cost)
                    }
                } else if viewModel.purchaseResult is PurchaseResult.Success {
                    let isTJ = item.category == .crossBusiness && item.id.hasPrefix("tutoringjay_")
                    Text(isTJ ? "Lesson Redeemed!" : "Purchased!")
                        .font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
                    if isTJ {
                        Text("Your trial lesson has been redeemed!")
                        Text("Book your lesson at portal.tutoringjay.com")
                            .fontWeight(.bold).foregroundColor(Color(hex: 0xE65100))
                    } else {
                        Text("\(item.name) unlocked!")
                    }
                    HStack(spacing: 12) {
                        if isTJ {
                            Button("Book Now") {
                                openTutoringJayBooking()
                                viewModel.dismissPurchaseDialog()
                            }
                            .fontWeight(.bold).foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Color(hex: 0xE65100)).cornerRadius(8)
                        }
                        Button("OK") { viewModel.dismissPurchaseDialog() }
                            .fontWeight(.bold).foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(KanjiJourneyTheme.primary).cornerRadius(8)
                    }
                } else {
                    Text("Purchase Failed")
                        .font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)
                    if viewModel.purchaseResult is PurchaseResult.InsufficientFunds {
                        Text("Not enough coins. Keep studying to earn more J Coins!")
                    } else if viewModel.purchaseResult is PurchaseResult.AlreadyOwned {
                        Text("You already own \(item.name).")
                    } else {
                        Text("Something went wrong. Please try again.")
                    }
                    Button("OK") { viewModel.dismissPurchaseDialog() }
                        .fontWeight(.bold).foregroundColor(.white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(KanjiJourneyTheme.primary).cornerRadius(8)
                }
            }
            .padding(24)
            .background(KanjiJourneyTheme.surface)
            .cornerRadius(16)
            .padding(32)
        }
    }

    private func categoryImageAsset(_ category: ShopCategory) -> String {
        switch category {
        case .theme: return "shop-themes.png"
        case .booster: return "shop-boosters.png"
        case .utility: return "shop-cosmetics.png"
        case .content: return "shop-themes.png"
        case .crossBusiness: return "shop-featured.png"
        default: return "shop-themes.png"
        }
    }

    private func openTutoringJayBooking() {
        if let url = URL(string: "https://portal.tutoringjay.com/schedule/book") {
            UIApplication.shared.open(url)
        }
    }
}
