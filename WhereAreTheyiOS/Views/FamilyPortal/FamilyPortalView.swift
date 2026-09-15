//
//  FamilyPortalView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct FamilyPortalView: View {
    @StateObject private var viewModel = FamilyPortalViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.06, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Title Banner
                    VStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.23, green: 0.51, blue: 0.96))
                        
                        Text("👨‍👩‍👧 بوابة الأسرة السرية")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("تابع حالة بلاغك ومعلومات البحث بخصوصية تامة")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Search Code Input Card
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("رمز البلاغ الموحد (مثال: AIN-MIS-2026-8812)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 10) {
                            Button(action: {
                                Task { await viewModel.search() }
                            }) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("بحث")
                                            .font(.system(size: 14, weight: .bold))
                                        Image(systemName: "magnifyingglass")
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            TextField("أدخل الرمز هنا...", text: $viewModel.searchCode)
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    
                    // Error state
                    if let err = viewModel.errorMessage {
                        Text(err)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                    }
                    
                    // Results View
                    if let data = viewModel.portalData {
                        ScrollView {
                            VStack(alignment: .trailing, spacing: 16) {
                                // Notice Info
                                if let notice = data.notice {
                                    NoticeCardView(notice: notice)
                                }
                                
                                // Timeline Header
                                Text("⏱️ سجل التحديثات والإفادات المعالجة")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                                
                                if data.updates.isEmpty {
                                    Text("لا توجد تحديثات جديدة مسجلة حالياً.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 20)
                                } else {
                                    VStack(alignment: .trailing, spacing: 14) {
                                        ForEach(data.updates) { update in
                                            HStack(alignment: .top, spacing: 12) {
                                                VStack(alignment: .trailing, spacing: 4) {
                                                    Text(update.content ?? "")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(.white)
                                                        .multilineTextAlignment(.trailing)
                                                    
                                                    if let date = update.createdAt {
                                                        Text(date)
                                                            .font(.system(size: 11))
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                .padding(12)
                                                .background(Color.white.opacity(0.04))
                                                .cornerRadius(12)
                                                
                                                Circle()
                                                    .fill(Color.blue)
                                                    .frame(width: 10, height: 10)
                                                    .padding(.top, 6)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        }
                    } else {
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
