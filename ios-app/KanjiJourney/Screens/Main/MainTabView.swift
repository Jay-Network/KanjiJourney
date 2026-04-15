import SwiftUI

/// Bottom tab navigation matching Android's MainScaffold.kt.
/// Four tabs: Main (Home), Study, Play (Games), Collect (Collection).
struct MainTabView: View {
    @EnvironmentObject var container: AppContainer
    let navigateTo: (NavRoute) -> Void

    @State private var selectedTab: BottomTab = .main

    init(navigateTo: @escaping (NavRoute) -> Void) {
        self.navigateTo = navigateTo
        // Glass-styled tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(hex: 0x08080F))
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: 0xFF6B35))
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: 0xFF6B35))]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Main (Home)
            HomeView(navigateTo: navigateTo)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Main")
                }
                .tag(BottomTab.main)

            // Tab 2: Study
            StudyTabView(navigateTo: navigateTo)
                .tabItem {
                    Image(systemName: "pencil.line")
                    Text("Study")
                }
                .tag(BottomTab.study)

            // Tab 3: Play (Games)
            GamesTabView(navigateTo: navigateTo)
                .tabItem {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .tag(BottomTab.play)

            // Tab 4: Collect
            CollectionHubView(navigateTo: navigateTo)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Collect")
                }
                .tag(BottomTab.collect)
        }
        .accentColor(GlassBrand.current)
    }
}

/// Bottom tab enum matching Android's BottomNavItem.
enum BottomTab: String, CaseIterable {
    case main
    case study
    case play
    case collect
}
