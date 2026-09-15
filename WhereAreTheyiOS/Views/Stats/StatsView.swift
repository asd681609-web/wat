//
//  StatsView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.06, blue: 0.12).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .trailing, spacing: 20) {
                        // Header Title
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("📊 إحصائيات المنصة الوطنية")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            Text("بيانات ومؤشرات الاستجابة الحية")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 16)
                        
                        // 2x2 Metric Cards Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            metricCard(title: "مفقود نشط", count: "\(viewModel.stats.totalMissing)", color: .red, icon: "exclamationmark.triangle.fill")
                            metricCard(title: "معثور عليه", count: "\(viewModel.stats.totalFound)", color: .green, icon: "checkmark.circle.fill")
                            metricCard(title: "تم الإيجاد", count: "\(viewModel.stats.totalResolved)", color: .blue, icon: "heart.fill")
                            metricCard(title: "متطوع معتمد", count: "\(viewModel.stats.totalVolunteers)", color: .orange, icon: "person.3.fill")
                        }
                        
                        // Resolution Progress Card
                        VStack(alignment: .trailing, spacing: 10) {
                            HStack {
                                Text("\(Int(viewModel.stats.resolutionRate * 100))%")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.green)
                                Spacer()
                                Text("نسبة نجاح الإيجاد")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            ProgressView(value: viewModel.stats.resolutionRate)
                                .tint(.green)
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                        
                        // Top Cities Roster
                        VStack(alignment: .trailing, spacing: 12) {
                            Text("أكثر المدن في عدد البلاغات")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            ForEach(viewModel.stats.byCity) { item in
                                HStack {
                                    Text("\(item.count)")
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(10)
                                    
                                    Spacer()
                                    
                                    Text(item.city ?? "غير محدد")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                }
                .refreshable {
                    await viewModel.loadStats()
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadStats()
        }
    }
    
    private func metricCard(title: String, count: String, color: Color, icon: String) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(count)
                .font(.system(size: 28, weight: .black))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(14)
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
