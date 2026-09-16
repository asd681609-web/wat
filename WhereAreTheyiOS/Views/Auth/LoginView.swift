//
//  LoginView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Login Screen matching Android LoginScreen
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var identifier: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo & Welcome Header
                        VStack(spacing: 8) {
                            Circle()
                                .fill(AinTheme.cyan.opacity(0.12))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(AinTheme.cyan)
                                )
                            Text("تسجيل الدخول للمنظومة")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AinTheme.textPrimary)
                            Text("للمتطوعين الميدانيين، المستشفيات، والجهات الرسمية")
                                .font(.system(size: 12))
                                .foregroundColor(AinTheme.textSecondary)
                        }
                        .padding(.top, 20)
                        
                        // Input Fields Card
                        VStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("البريد الإلكتروني أو رقم الهاتف")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AinTheme.textSecondary)
                                TextField("example@email.com", text: $identifier)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(AinTheme.bgTertiary)
                                    .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("كلمة المرور")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AinTheme.textSecondary)
                                SecureField("••••••••", text: $password)
                                    .font(.system(size: 14))
                                    .padding(12)
                                    .background(AinTheme.bgTertiary)
                                    .cornerRadius(12)
                            }
                            
                            if let error = errorMessage {
                                Text(error)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AinTheme.red)
                            }
                            
                            Button(action: handleLogin) {
                                HStack {
                                    if isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("دخول")
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AinTheme.cyan)
                                .cornerRadius(12)
                            }
                            .disabled(identifier.isEmpty || password.isEmpty || isLoading)
                        }
                        .padding(18)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AinTheme.border, lineWidth: 1))
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("حسابي")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func handleLogin() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let res = try await APIService.shared.login(identifier: identifier, password: password)
                await MainActor.run {
                    authManager.saveSession(
                        token: res.token,
                        userId: res.userId,
                        name: res.name,
                        role: res.role,
                        entityType: res.entityType
                    )
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
