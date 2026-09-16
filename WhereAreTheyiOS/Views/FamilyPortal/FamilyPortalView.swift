//
//  FamilyPortalView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Family Portal matching Android FamilyPortalScreen
//

import SwiftUI

struct FamilyPortalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    @State private var portalData: FamilyPortalData? = nil
    @State private var isSearching: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Box
                        VStack(spacing: 8) {
                            Circle()
                                .fill(AinTheme.purple.opacity(0.12))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AinTheme.purple)
                                )
                            Text("بوابة تتبع العائلات الخاصة")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AinTheme.textPrimary)
                            Text("أدخل رمز البلاغ السري المُسلّم إليك لمتابعة آخر تحديثات البحث")
                                .font(.system(size: 12))
                                .foregroundColor(AinTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)
                        
                        // Search Bar
                        HStack(spacing: 10) {
                            TextField("مثال: WAT-8492", text: $code)
                                .font(.system(size: 14, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(12)
                                .background(AinTheme.bgSecondary)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AinTheme.border, lineWidth: 1))
                            
                            Button(action: searchPortal) {
                                HStack {
                                    if isSearching {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                        Text("استعلام")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(AinTheme.purple)
                                .cornerRadius(12)
                            }
                            .disabled(code.isEmpty || isSearching)
                        }
                        .padding(.horizontal, 16)
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AinTheme.red)
                                .padding(10)
                        }
                        
                        // Results Card
                        if let data = portalData, let notice = data.notice {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Text(notice.displayName)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AinTheme.textPrimary)
                                    Spacer()
                                    Text(notice.status ?? "نشط")
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AinTheme.emeraldSurface)
                                        .foregroundColor(AinTheme.emerald)
                                        .cornerRadius(8)
                                }
                                
                                Divider()
                                
                                Text("سجل التحديثات الميدانية:")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AinTheme.textSecondary)
                                
                                if let updates = data.updates, !updates.isEmpty {
                                    ForEach(updates) { tip in
                                        HStack(alignment: .top, spacing: 8) {
                                            Circle().fill(AinTheme.purple).frame(width: 8, height: 8).offset(y: 5)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(tip.content ?? "إفادة واردة")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AinTheme.textPrimary)
                                                if let date = tip.createdAt {
                                                    Text(date).font(.system(size: 10)).foregroundColor(AinTheme.textMuted)
                                                }
                                            }
                                        }
                                        .padding(8)
                                        .background(AinTheme.bgTertiary)
                                        .cornerRadius(8)
                                    }
                                } else {
                                    Text("لا توجد إفادات أو مشاهدات جديدة حتى اللحظة. فرق البحث تواصل العمل.")
                                        .font(.system(size: 12))
                                        .foregroundColor(AinTheme.textMuted)
                                }
                            }
                            .padding(16)
                            .background(AinTheme.bgSecondary)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") { dismiss() }
                        .foregroundColor(AinTheme.textMuted)
                }
            }
        }
    }

    private func searchPortal() {
        let q = code.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        isSearching = true
        errorMessage = nil
        Task {
            do {
                let res = try await APIService.shared.searchFamilyPortal(code: q)
                await MainActor.run {
                    self.portalData = res
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSearching = false
                }
            }
        }
    }
}
