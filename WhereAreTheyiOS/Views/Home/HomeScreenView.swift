//
//  HomeScreenView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (Ø£ÙŠÙ† Ù‡Ù…) â€” Live Sync HomeScreen matching Android
//

import SwiftUI

struct HomeScreenView: View {
    let onNoticeClick: (Int) -> Void
    let onReportMissing: () -> Void
    let onReportFound: () -> Void
    let onMedicalScanner: () -> Void
    let onFamilyPortal: () -> Void
    let onWhyAinHum: () -> Void

    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var amberSync = AmberAlertSyncManager.shared
    @State private var showingNoAlertsSheet: Bool = false
    @State private var lockscreenTestScheduled: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 14) {
                        // Live AMBER Alert Siren Banner (if any active broadcasts in database)
                        if !amberSync.activeAlerts.isEmpty {
                            AmberAlertBannerView(alerts: amberSync.activeAlerts) { alert in
                                amberSync.showSpecificAlert(alert)
                            }
                        }
                        
                        // Lockscreen test countdown banner if scheduled
                        if lockscreenTestScheduled {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(AinTheme.amber)
                                Text("ØªÙ…Øª Ø¬Ø¯ÙˆÙ„Ø© ØªÙ†Ø¨ÙŠÙ‡ Ø§Ù„Ø·ÙˆØ§Ø±Ø¦ Ø¨Ø¹Ø¯ 5 Ø«ÙˆØ§Ù†Ù â€” Ø§Ù‚ÙÙ„ Ù‡Ø§ØªÙÙƒ Ø§Ù„Ø¢Ù† Ù„ØªØ¬Ø±Ø¨Ø© Ø´Ø§Ø´Ø© Ø§Ù„Ù‚ÙÙ„!")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                            }
                            .padding(12)
                            .background(AinTheme.amber.opacity(0.15))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AinTheme.amber, lineWidth: 1))
                            .padding(.horizontal, 16)
                        }
                        
                        // Search & City Header
                        searchAndFilterSection
                        
                        // Fast Action Buttons: Ø¥Ø¨Ù„Ø§Øº Ø¹Ù† Ù…ÙÙ‚ÙˆØ¯ / Ù…Ø¹Ø«ÙˆØ± Ø¹Ù„ÙŠÙ‡
                        quickActionButtons
                        
                        // Secondary Services: Ø¨ÙˆØ§Ø¨Ø© Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©ØŒ Ø§Ù„Ù…Ø§Ø³Ø­ Ø§Ù„Ø·Ø¨ÙŠØŒ Ø¹Ù† Ø§Ù„Ù…Ù†ØµØ©
                        quickServicesRow
                        
                        // Partner Agencies Marquee
                        PartnerMarqueeView()
                        
                        // Filter Category Chips (Ø§Ù„ÙƒÙ„ØŒ Ù…ÙÙ‚ÙˆØ¯ØŒ Ù…Ø¹Ø«ÙˆØ± Ø¹Ù„ÙŠÙ‡ØŒ Ø¥Ù„Ø®)
                        filterChipsRow
                        
                        // Notices Feed
                        noticesListSection
                        
                        // Extra bottom spacing for floating tab bar
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 8)
                }
                .refreshable {
                    await viewModel.refresh()
                    await amberSync.syncAmberAlerts(triggerPopupOnNew: false)
                }

                // Full-Screen AMBER Alert Emergency Dialog Overlay (Real-time synced with backend)
                if let alert = amberSync.currentActiveAlert {
                    AmberAlertModalView(
                        alert: alert,
                        onDismiss: {
                            amberSync.dismissCurrentAlert()
                        },
                        onViewDetails: { code in
                            amberSync.dismissCurrentAlert()
                            if let notice = viewModel.notices.first(where: { $0.uniqueCode == code }) {
                                onNoticeClick(notice.id)
                            } else if let nId = alert.noticeId {
                                onNoticeClick(nId)
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(999)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.badge.questionmark.fill")
                            .foregroundColor(AinTheme.cyan)
                            .font(.system(size: 18))
                        Text("Ù…Ù†ØµØ© Ø£ÙŠÙ† Ù‡Ù…")
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(AinTheme.textPrimary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let firstAlert = amberSync.activeAlerts.first {
                            amberSync.showSpecificAlert(firstAlert)
                        } else {
                            showingNoAlertsSheet = true
                        }
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(!amberSync.activeAlerts.isEmpty ? AinTheme.red : AinTheme.cyan)
                                .font(.system(size: 18))
                            
                            if !amberSync.activeAlerts.isEmpty {
                                Circle()
                                    .fill(AinTheme.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                }
            }
            .actionSheet(isPresented: $showingNoAlertsSheet) {
                ActionSheet(
                    title: Text("Ù…Ø±ÙƒØ² ØªÙ†Ø¨ÙŠÙ‡Ø§Øª Ø§Ù„Ø·ÙˆØ§Ø±Ø¦ AMBER"),
                    message: Text("Ø§Ù„Ù†Ø¸Ø§Ù… Ù…ØªØµÙ„ ÙˆÙŠØ±Ø§Ù‚Ø¨ Ø§Ù„Ø¨Ù„Ø§ØºØ§Øª Ø§Ù„Ø­ÙŠØ© ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹. ÙŠÙ…ÙƒÙ†Ùƒ ØªØ¬Ø±Ø¨Ø© ØµÙØ§Ø±Ø© Ø§Ù„Ø¥Ù†Ø°Ø§Ø± Ø£Ùˆ Ø§Ø®ØªØ¨Ø§Ø± Ø§Ù„ØªÙ†Ø¨ÙŠÙ‡ Ø¹Ù„Ù‰ Ø´Ø§Ø´Ø© Ø§Ù„Ù‚ÙÙ„ Ø¹Ù†Ø¯ Ø¥ØºÙ„Ø§Ù‚ Ø§Ù„Ù‡Ø§ØªÙ:"),
                    buttons: [
                        .default(Text("ðŸš¨ ØªØ¬Ø±Ø¨Ø© ØµÙØ§Ø±Ø© Ø§Ù„Ø¥Ù†Ø°Ø§Ø± ÙˆØ§Ù„ÙÙ„Ø§Ø´ (Ø¯Ø§Ø®Ù„ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚)")) {
                            amberSync.testSirenAlert()
                        },
                        .default(Text("ðŸ“² ØªØ¬Ø±Ø¨Ø© Ø§Ù„ØªÙ†Ø¨ÙŠÙ‡ Ø¹Ù„Ù‰ Ø´Ø§Ø´Ø© Ø§Ù„Ù‚ÙÙ„ (Ø¨Ø¹Ø¯ 5 Ø«ÙˆØ§Ù†Ù)")) {
                            lockscreenTestScheduled = true
                            NotificationManager.shared.scheduleLockscreenTest(delaySeconds: 5.0)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                                lockscreenTestScheduled = false
                            }
                        },
                        .cancel(Text("Ø¥ØºÙ„Ø§Ù‚"))
                    ]
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadData()
            NotificationManager.shared.requestNotificationPermission()
        }
    }

    // MARK: - Search & City Section
    private var searchAndFilterSection: some View {
        HStack(spacing: 10) {
            // Search Input Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AinTheme.textMuted)
                TextField("Ø§Ø¨Ø­Ø« Ø¨Ø§Ù„Ø§Ø³Ù…ØŒ Ø§Ù„Ù…Ø¯ÙŠÙ†Ø©ØŒ Ø£Ùˆ Ø§Ù„Ø±Ù…Ø²...", text: $viewModel.searchQuery)
                    .font(.system(size: 13))
                    .foregroundColor(AinTheme.textPrimary)
                    .onChange(of: viewModel.searchQuery) { _ in
                        viewModel.filterNotices()
                    }
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                        viewModel.filterNotices()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AinTheme.textMuted)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AinTheme.bgSecondary)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AinTheme.border, lineWidth: 1))
            
            // City Selector
            Menu {
                ForEach(viewModel.cities, id: \.self) { city in
                    Button(city) {
                        viewModel.selectedCity = city
                        viewModel.filterNotices()
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AinTheme.cyan)
                    Text(viewModel.selectedCity)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(AinTheme.bgSecondary)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AinTheme.border, lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Quick Action Buttons (Ø¥Ø¨Ù„Ø§Øº Ø¹Ù† Ù…ÙÙ‚ÙˆØ¯ / Ù…Ø¹Ø«ÙˆØ± Ø¹Ù„ÙŠÙ‡)
    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            // Report Missing (Red)
            Button(action: onReportMissing) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                    Text("Ø¥Ø¨Ù„Ø§Øº Ø¹Ù† Ù…ÙÙ‚ÙˆØ¯")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [AinTheme.red, AinTheme.redDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(14)
                .shadow(color: AinTheme.redGlow, radius: 4, x: 0, y: 2)
            }
            
            // Report Found (Cyan)
            Button(action: onReportFound) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 16))
                    Text("Ø¥Ø¨Ù„Ø§Øº Ø¹Ù† Ù…Ø¹Ø«ÙˆØ± Ø¹Ù„ÙŠÙ‡")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [AinTheme.cyan, AinTheme.cyanDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(14)
                .shadow(color: AinTheme.cyan.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Quick Services Row (Ø¨ÙˆØ§Ø¨Ø© Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©ØŒ Ø§Ù„Ù…Ø§Ø³Ø­ Ø§Ù„Ø·Ø¨ÙŠØŒ Ø¹Ù† Ø§Ù„Ù…Ù†ØµØ©)
    private var quickServicesRow: some View {
        HStack(spacing: 10) {
            servicePill(title: "Ø¨ÙˆØ§Ø¨Ø© Ø§Ù„Ø¹Ø§Ø¦Ù„Ø©", icon: "person.2.fill", color: AinTheme.purple, action: onFamilyPortal)
            servicePill(title: "Ø§Ù„Ù…Ø§Ø³Ø­ Ø§Ù„Ø·Ø¨ÙŠ", icon: "cross.case.fill", color: AinTheme.emerald, action: onMedicalScanner)
            servicePill(title: "Ø¹Ù† Ø§Ù„Ù…Ù†ØµØ©", icon: "info.circle.fill", color: AinTheme.cyan, action: onWhyAinHum)
        }
        .padding(.horizontal, 16)
    }

    private func servicePill(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AinTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(AinTheme.bgSecondary)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AinTheme.border, lineWidth: 1))
        }
    }

    // MARK: - Filter Chips Row
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(title: "Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø¨Ù„Ø§ØºØ§Øª", type: "all")
                chipButton(title: "Ù…ÙÙ‚ÙˆØ¯ÙŠÙ† ÙÙ‚Ø· ðŸš¨", type: "missing")
                chipButton(title: "Ù…Ø¹Ø«ÙˆØ± Ø¹Ù„ÙŠÙ‡Ù… âœ…", type: "found")
                chipButton(title: "Ù…ØªÙˆÙÙŠÙ† Ù…Ø¬Ù‡ÙˆÙ„ÙŠÙ†", type: "deceased")
            }
            .padding(.horizontal, 16)
        }
    }

    private func chipButton(title: String, type: String) -> some View {
        let isSelected = viewModel.selectedType == type
        return Button(action: {
            viewModel.selectedType = type
            viewModel.filterNotices()
        }) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : AinTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AinTheme.cyan : AinTheme.bgSecondary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? AinTheme.cyan : AinTheme.border, lineWidth: 1)
                )
        }
    }

    // MARK: - Notices List Section (Real Live Notices from Server)
    private var noticesListSection: some View {
        LazyVStack(spacing: 8) {
            if viewModel.isLoading && viewModel.filteredNotices.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(AinTheme.cyan)
                    Text("Ø¬Ø§Ø±Ù Ø¬Ù„Ø¨ Ø§Ù„Ø¨Ù„Ø§ØºØ§Øª Ø§Ù„Ø­ÙŠØ© Ù…Ù† Ø®Ø§Ø¯Ù… Ø£ÙŠÙ† Ù‡Ù…...")
                        .font(.system(size: 13))
                        .foregroundColor(AinTheme.textMuted)
                }
                .padding(30)
            } else if viewModel.filteredNotices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(AinTheme.textMuted)
                    Text("Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¨Ù„Ø§ØºØ§Øª ØªØ·Ø§Ø¨Ù‚ Ø§Ù„Ø¨Ø­Ø« Ø­Ø§Ù„ÙŠØ§Ù‹")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AinTheme.textSecondary)
                    Text("ÙŠØªÙ… ÙØ­Øµ Ù‚Ø§Ø¹Ø¯Ø© Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ù…Ø±ÙƒØ²ÙŠØ© Ø¨Ø´ÙƒÙ„ Ù…Ø³ØªÙ…Ø±")
                        .font(.system(size: 12))
                        .foregroundColor(AinTheme.textMuted)
                }
                .padding(.vertical, 40)
            } else {
                ForEach(viewModel.filteredNotices) { notice in
                    ModernNoticeCardView(notice: notice) {
                        onNoticeClick(notice.id)
                    }
                }
            }
        }
    }
}