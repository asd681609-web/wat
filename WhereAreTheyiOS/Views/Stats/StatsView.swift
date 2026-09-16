//
//  StatsView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Live Analytics matching Android StatsScreen
//

import SwiftUI

struct StatsView: View {
    @State private var stats: PlatformStats = PlatformStats.placeholder
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 2x2 Grid of KPIs
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            kpiCard(title: "حالات نشطة", value: "\(stats.totalMissing)", icon: "person.crop.circle.badge.exclamationmark", color: AinTheme.red)
                            kpiCard(title: "تم العثور عليهم", value: "\(stats.totalFound)", icon: "checkmark.seal.fill", color: AinTheme.emerald)
                            kpiCard(title: "نسبة الاستجابة", value: "\(String(format: "%.1f", stats.resolutionRate))%", icon: "chart.line.uptrend.xyaxis", color: AinTheme.cyan)
                            kpiCard(title: "متطوعون معتمدون", value: "\(stats.totalVolunteers)", icon: "person.3.fill", color: AinTheme.purple)
                        }
                        .padding(.horizontal, 16)
                        
                        // Response Time Summary Card
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(AinTheme.amber.opacity(0.15)).frame(width: 44, height: 44)
                                Image(systemName: "clock.badge.checkmark.fill")
                                    .foregroundColor(AinTheme.amber)
                                    .font(.system(size: 20))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("متوسط وقت حسم البلاغ")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                Text("\(String(format: "%.1f", stats.avgDaysToResolve)) يوم فقط منذ تسجيل البلاغ")
                                    .font(.system(size: 12))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                        
                        // City Breakdown Section
                        if let cities = stats.byCity, !cities.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("توزيع البلاغات حسب المدن الليبية")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                
                                ForEach(cities) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(item.city ?? "أخرى")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(AinTheme.textPrimary)
                                            Spacer()
                                            Text("\(item.count) بلاغ")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(AinTheme.cyan)
                                        }
                                        GeometryReader { geo in
                                            let maxCount = max(cities.map { $0.count }.max() ?? 1, 1)
                                            let ratio = CGFloat(item.count) / CGFloat(maxCount)
                                            ZStack(alignment: .leading) {
                                                Capsule().fill(AinTheme.bgTertiary).frame(height: 8)
                                                Capsule().fill(AinTheme.cyan).frame(width: geo.size.width * ratio, height: 8)
                                            }
                                        }
                                        .frame(height: 8)
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            .padding(14)
                            .background(AinTheme.bgSecondary)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("المؤشرات والإحصائيات الحية")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadStats()
        }
    }

    private func kpiCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                    .overlay(Image(systemName: icon).foregroundColor(color).font(.system(size: 16)))
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(AinTheme.textPrimary)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AinTheme.textSecondary)
            }
        }
        .padding(14)
        .background(AinTheme.bgSecondary)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
    }

    private func loadStats() {
        Task {
            do {
                let res = try await APIService.shared.fetchStats()
                await MainActor.run {
                    self.stats = res
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}
