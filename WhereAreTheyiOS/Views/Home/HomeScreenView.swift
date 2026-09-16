//
//  HomeScreenView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Live Sync HomeScreen matching Android
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
                                Text("تمت جدولة تنبيه الطوارئ بعد 5 ثوانٍ — اقفل هاتفك الآن لتجربة شاشة القفل!")
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
                        
                        // Fast Action Buttons: إبلاغ عن مفقود / معثور عليه
                        quickActionButtons
                        
                        // Secondary Services: بوابة العائلة، الماسح الطبي، عن المنصة
                        quickServicesRow
                        
                        // Partner Agencies Marquee
                        PartnerMarqueeView()
                        
                        // Filter Category Chips (الكل، مفقود، معثور عليه، إلخ)
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
                        Text("منصة أين هم")
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
                    title: Text("مركز تنبيهات الطوارئ AMBER"),
                    message: Text("النظام متصل ويراقب البلاغات الحية تلقائياً. يمكنك تجربة صفارة الإنذار أو اختبار التنبيه على شاشة القفل عند إغلاق الهاتف:"),
                    buttons: [
                        .default(Text("🚨 تجربة صفارة الإنذار والفلاش (داخل التطبيق)")) {
                            amberSync.testSirenAlert()
                        },
                        .default(Text("📲 تجربة التنبيه على شاشة القفل (بعد 5 ثوانٍ)")) {
                            lockscreenTestScheduled = true
                            NotificationManager.shared.scheduleLockscreenTest(delaySeconds: 5.0)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                                lockscreenTestScheduled = false
                            }
                        },
                        .cancel(Text("إغلاق"))
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
                TextField("ابحث بالاسم، المدينة، أو الرمز...", text: $viewModel.searchQuery)
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

    // MARK: - Quick Action Buttons (إبلاغ عن مفقود / معثور عليه)
    private var quickActionButtons: some View {
        HStack(spacing: 12) {
            // Report Missing (Red)
            Button(action: onReportMissing) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                    Text("إبلاغ عن مفقود")
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
                    Text("إبلاغ عن معثور عليه")
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

    // MARK: - Quick Services Row (بوابة العائلة، الماسح الطبي، عن المنصة)
    private var quickServicesRow: some View {
        HStack(spacing: 10) {
            servicePill(title: "بوابة العائلة", icon: "person.2.fill", color: AinTheme.purple, action: onFamilyPortal)
            servicePill(title: "الماسح الطبي", icon: "cross.case.fill", color: AinTheme.emerald, action: onMedicalScanner)
            servicePill(title: "عن المنصة", icon: "info.circle.fill", color: AinTheme.cyan, action: onWhyAinHum)
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
                chipButton(title: "جميع البلاغات", type: "all")
                chipButton(title: "مفقودين فقط 🚨", type: "missing")
                chipButton(title: "معثور عليهم ✅", type: "found")
                chipButton(title: "متوفين مجهولين", type: "deceased")
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
                    Text("جارِ جلب البلاغات الحية من خادم أين هم...")
                        .font(.system(size: 13))
                        .foregroundColor(AinTheme.textMuted)
                }
                .padding(30)
            } else if viewModel.filteredNotices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(AinTheme.textMuted)
                    Text("لا توجد بلاغات تطابق البحث حالياً")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AinTheme.textSecondary)
                    Text("يتم فحص قاعدة البيانات المركزية بشكل مستمر")
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
