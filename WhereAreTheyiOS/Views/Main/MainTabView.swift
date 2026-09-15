//
//  MainTabView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    init() {
        // Dark TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.04, green: 0.06, blue: 0.12, alpha: 1.0)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NoticeListView()
                .tabItem {
                    Label("الرئيسية", systemImage: "rectangle.grid.1x2.fill")
                }
                .tag(0)
            
            IntelMapView()
                .tabItem {
                    Label("الخريطة", systemImage: "map.fill")
                }
                .tag(1)
            
            FamilyPortalView()
                .tabItem {
                    Label("بوابة الأسرة", systemImage: "lock.shield.fill")
                }
                .tag(2)
            
            StatsView()
                .tabItem {
                    Label("الإحصائيات", systemImage: "chart.bar.fill")
                }
                .tag(3)
        }
        .accentColor(Color(red: 0.94, green: 0.27, blue: 0.27))
    }
}
