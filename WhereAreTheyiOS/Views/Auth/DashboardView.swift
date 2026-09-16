//
//  DashboardView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — User Dashboard matching Android DashboardScreen
//

import SwiftUI

struct DashboardView: View {
    let onNoticeClick: (Int) -> Void
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var locationManager = LocationManager.shared
    @State private var isFieldOnline: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // User Profile Card
                        HStack(spacing: 14) {
                            Circle()
                                .fill(AinTheme.cyan.opacity(0.15))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 26))
                                        .foregroundColor(AinTheme.cyan)
                                )
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(authManager.userName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                
                                Text(roleBadgeTitle(role: authManager.userRole))
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AinTheme.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(AinTheme.cyanSurface)
                                    .cornerRadius(6)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AinTheme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        // Volunteer Live Tracking Toggle
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Circle().fill(isFieldOnline ? AinTheme.emerald : AinTheme.textMuted).frame(width: 8, height: 8)
                                Text("التواجد الميداني المباشر (GPS)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                Spacer()
                                Toggle("", isOn: $isFieldOnline)
                                    .tint(AinTheme.emerald)
                                    .onChange(of: isFieldOnline) { online in
                                        if online {
                                            locationManager.startLiveFieldTracking(
                                                userId: authManager.userId,
                                                name: authManager.userName,
                                                phone: "",
                                                city: authManager.userCity
                                            )
                                        } else {
                                            locationManager.stopLiveFieldTracking()
                                        }
                                    }
                            }
                            Text("عند التفعيل، يتم بث موقعك لغرفة العمليات المركزية لتوجيه أقرب بلاغات إليك.")
                                .font(.system(size: 11))
                                .foregroundColor(AinTheme.textSecondary)
                        }
                        .padding(16)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AinTheme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                        
                        // Logout Button
                        Button(action: {
                            locationManager.stopLiveFieldTracking()
                            authManager.logout()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("تسجيل الخروج من الحساب")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(AinTheme.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AinTheme.redSurface)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AinTheme.redLight.opacity(0.4), lineWidth: 1))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        Spacer().frame(height: 80)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("لوحة التحكم الميدانية")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func roleBadgeTitle(role: String) -> String {
        switch role {
        case "volunteer": return "متطوع بحث وإنقاذ معتمد 🎖️"
        case "hospital": return "كوادر طبية ومستشفيات 🏥"
        case "border", "border_outlet": return "أمن المنافذ الحدودية 🛡️"
        case "admin": return "إدارة العمليات المركزية ⭐️"
        default: return "مواطن مساهم 👤"
        }
    }
}
