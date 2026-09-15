//
//  NoticeDetailView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct NoticeDetailView: View {
    let notice: Notice
    @State private var showTipSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 20) {
                
                // Photo Header with Status Badge
                ZStack(alignment: .bottomTrailing) {
                    if let photoURL = notice.fullPhotoURL {
                        AsyncImage(url: photoURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 280)
                                .clipped()
                        } placeholder: {
                            Color(red: 0.08, green: 0.12, blue: 0.2)
                                .frame(height: 280)
                        }
                    } else {
                        Color(red: 0.08, green: 0.12, blue: 0.2)
                            .frame(height: 280)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray.opacity(0.4))
                            )
                    }
                    
                    // Gradient overlay
                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color(red: 0.04, green: 0.06, blue: 0.12)]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 120)
                    
                    HStack {
                        StatusBadge(type: notice.type ?? "missing")
                        Spacer()
                        if let code = notice.uniqueCode {
                            Text("رمز البلاغ: #\(code)")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(16)
                }
                
                VStack(alignment: .trailing, spacing: 18) {
                    // Full Name
                    Text(notice.fullName ?? "اسم غير معروف")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .environment(\.layoutDirection, .rightToLeft)
                    
                    // Main Info Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        infoCard(title: "المدينة", value: notice.city ?? "غير محدد", icon: "mappin.circle.fill", color: .blue)
                        infoCard(title: "العمر التقديري", value: notice.ageEstimate != nil ? "\(notice.ageEstimate!) سنة" : "غير محدد", icon: "calendar", color: .orange)
                        infoCard(title: "الجنس", value: notice.gender ?? "غير محدد", icon: "person.fill", color: .purple)
                        infoCard(title: "تاريخ الفقدان", value: notice.lastSeenDate ?? "غير محدد", icon: "clock.fill", color: .red)
                    }
                    
                    // Medical Section
                    if let chronic = notice.chronicDiseases, !chronic.isEmpty {
                        VStack(alignment: .trailing, spacing: 8) {
                            HStack {
                                Spacer()
                                Text("الملف الطبي والصحي الحرِج")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                                Image(systemName: "cross.case.fill")
                                    .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                            }
                            
                            Text(chronic)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(14)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                    
                    // Belongings Section
                    if let belongings = notice.personalBelongings, !belongings.isEmpty {
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("المقتنيات والملابس وقت الفقدان:")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(belongings)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(12)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showTipSheet = true
                        }) {
                            HStack {
                                Spacer()
                                Text("إرسال إفادة / مشاهدة ميدانية")
                                    .font(.system(size: 16, weight: .bold))
                                Image(systemName: "paperplane.fill")
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(red: 0.94, green: 0.27, blue: 0.27), Color(red: 0.8, green: 0.15, blue: 0.15)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {
                            if let phoneURL = URL(string: "tel://1515") {
                                UIApplication.shared.open(phoneURL)
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("الاتصال بمركز بلاغات الطوارئ 1515")
                                    .font(.system(size: 15, weight: .semibold))
                                Image(systemName: "phone.fill")
                                Spacer()
                            }
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(16)
            }
        }
        .background(Color(red: 0.04, green: 0.06, blue: 0.12).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTipSheet) {
            SubmitTipView(noticeCode: notice.uniqueCode ?? "\(notice.id)")
        }
    }
    
    private func infoCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(12)
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}
