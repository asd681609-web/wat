//
//  MainTabView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — 5-Tab Navigation matching Android NavGraph
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case home = 0
    case opsChat = 1
    case map = 2
    case stats = 3
    case profile = 4

    var title: String {
        switch self {
        case .home: return "الرئيسية"
        case .opsChat: return "الدردشة"
        case .map: return "الخريطة"
        case .stats: return "الإحصائيات"
        case .profile: return "حسابي"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .opsChat: return "message.badge.filled.fill"
        case .map: return "map.fill"
        case .stats: return "chart.bar.xaxis"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var authManager = AuthManager.shared
    
    // Navigation Sheets / Destination
    @State private var selectedNoticeId: Int? = nil
    @State private var showReportMissing: Bool = false
    @State private var showReportFound: Bool = false
    @State private var showFamilyPortal: Bool = false
    @State private var showMedicalScanner: Bool = false
    @State private var showWhyAinHum: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content Views
            Group {
                switch selectedTab {
                case .home:
                    HomeScreenView(
                        onNoticeClick: { id in selectedNoticeId = id },
                        onReportMissing: { showReportMissing = true },
                        onReportFound: { showReportFound = true },
                        onMedicalScanner: { showMedicalScanner = true },
                        onFamilyPortal: { showFamilyPortal = true },
                        onWhyAinHum: { showWhyAinHum = true }
                    )
                case .opsChat:
                    OpsChatView()
                case .map:
                    IntelMapView(onNoticeClick: { id in selectedNoticeId = id })
                case .stats:
                    StatsView()
                case .profile:
                    if authManager.isLoggedIn {
                        DashboardView(onNoticeClick: { id in selectedNoticeId = id })
                    } else {
                        LoginView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Elevated Floating Bottom Navigation Bar
            customBottomBar
        }
        .edgesIgnoringSafeArea(.bottom)
        // Sheets & Full Screens
        .sheet(item: Binding(
            get: { selectedNoticeId.map { NoticeIdWrapper(id: $0) } },
            set: { selectedNoticeId = $0?.id }
        )) { wrapper in
            NoticeDetailView(noticeId: wrapper.id)
        }
        .sheet(isPresented: $showReportMissing) {
            ReportView(type: "missing")
        }
        .sheet(isPresented: $showReportFound) {
            ReportView(type: "found")
        }
        .sheet(isPresented: $showFamilyPortal) {
            FamilyPortalView()
        }
        .sheet(isPresented: $showMedicalScanner) {
            MedicalScannerView(onNoticeClick: { id in
                showMedicalScanner = false
                selectedNoticeId = id
            })
        }
        .sheet(isPresented: $showWhyAinHum) {
            WhyAinHumView()
        }
    }

    // MARK: - Custom Bottom Navigation Bar
    private var customBottomBar: some View {
        VStack(spacing: 0) {
            Divider().background(AinTheme.divider)
            
            HStack(alignment: .bottom, spacing: 0) {
                // Tab 0: Home
                tabButton(tab: .home)
                
                // Tab 1: Ops Chat
                tabButton(tab: .opsChat)
                
                // Tab 2: Map (Elevated Center Cyan Circle)
                centerMapButton
                
                // Tab 3: Stats
                tabButton(tab: .stats)
                
                // Tab 4: Profile / Dashboard
                tabButton(tab: .profile)
            }
            .padding(.top, 8)
            .padding(.bottom, 28) // Bottom safe area
            .background(AinTheme.bgSecondary)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -2)
        }
    }

    private func tabButton(tab: TabItem) -> some View {
        let isSelected = selectedTab == tab
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? AinTheme.cyan : AinTheme.textMuted)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? AinTheme.cyan : AinTheme.textMuted)
                
                if isSelected {
                    Circle()
                        .fill(AinTheme.cyan)
                        .frame(width: 4, height: 4)
                } else {
                    Spacer().frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // Elevated Center Cyan Circle Map Button matching Android
    private var centerMapButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = .map
            }
        }) {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(AinTheme.cyan)
                        .frame(width: 52, height: 52)
                        .shadow(color: AinTheme.cyan.opacity(0.4), radius: 6, x: 0, y: 3)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                    
                    Image(systemName: "map.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .offset(y: -14)
                
                Text("الخريطة")
                    .font(.system(size: 11, weight: selectedTab == .map ? .bold : .medium))
                    .foregroundColor(selectedTab == .map ? AinTheme.cyan : AinTheme.textMuted)
                    .offset(y: -10)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct NoticeIdWrapper: Identifiable {
    let id: Int
}
