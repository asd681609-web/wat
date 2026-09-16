//
//  SubmitTipView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Confidential Tip Screen matching Android SubmitTipScreen
//

import SwiftUI

struct SubmitTipView: View {
    let noticeCode: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var locationDescription: String = ""
    @State private var contactPhone: String = ""
    @State private var isAnonymous: Bool = true
    @State private var isSubmitting: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var isSuccess: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Confidential Guarantee Banner
                        HStack(spacing: 12) {
                            Circle()
                                .fill(AinTheme.cyan.opacity(0.15))
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "shield.checkmark.fill").foregroundColor(AinTheme.cyan))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("إفادة سرية ومشفرة")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                Text("تصل مشاهدتك إلى ضابط عمليات البحث والإنقاذ مباشرة وبسرية تامة")
                                    .font(.system(size: 11))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                        
                        // Notice Code Tag
                        HStack {
                            Text("البلاغ المستهدف:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AinTheme.textSecondary)
                            Spacer()
                            Text("#\(noticeCode)")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(AinTheme.cyan)
                        }
                        .padding(12)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(12)
                        
                        // Anonymous Toggle
                        Toggle(isOn: $isAnonymous) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("إرسال كمواطن مجهول الهوية")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                Text("لن يتم تسجيل أو إظهار أية بيانات شخصية عنك")
                                    .font(.system(size: 11))
                                    .foregroundColor(AinTheme.textMuted)
                            }
                        }
                        .tint(AinTheme.cyan)
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(14)
                        
                        // Content Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("تفاصيل المشاهدة أو الإفادة *")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AinTheme.textSecondary)
                            
                            TextEditor(text: $content)
                                .frame(height: 110)
                                .padding(8)
                                .background(AinTheme.bgTertiary)
                                .cornerRadius(10)
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(14)
                        
                        // Location Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text("مكان أو عنوان المشاهدة بالتحديد *")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AinTheme.textSecondary)
                            TextField("مثال: بالقرب من مستشفى الجلاء، داخل سيارة...", text: $locationDescription)
                                .font(.system(size: 13))
                                .padding(12)
                                .background(AinTheme.bgTertiary)
                                .cornerRadius(10)
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(14)
                        
                        // Contact Phone (optional if not anonymous)
                        if !isAnonymous {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("رقم هاتفك (للتواصل معك في حال الحاجة لتوضيح)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AinTheme.textSecondary)
                                TextField("09xxxxxxxx", text: $contactPhone)
                                    .keyboardType(.phonePad)
                                    .font(.system(size: 13))
                                    .padding(12)
                                    .background(AinTheme.bgTertiary)
                                    .cornerRadius(10)
                            }
                            .padding(14)
                            .background(AinTheme.bgSecondary)
                            .cornerRadius(14)
                        }
                        
                        // Submit Button
                        Button(action: submitTip) {
                            HStack {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("إرسال الإفادة لغرفة العمليات")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AinTheme.cyan)
                            .cornerRadius(14)
                            .shadow(color: AinTheme.cyan.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isSubmitting)
                        
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إلغاء") { dismiss() }
                        .foregroundColor(AinTheme.textMuted)
                }
                ToolbarItem(placement: .principal) {
                    Text("تقديم إفادة سرية")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isSuccess ? "شكراً لمساهمتك" : "تنبيه"),
                    message: Text(alertMessage ?? ""),
                    dismissButton: .default(Text("حسناً")) {
                        if isSuccess { dismiss() }
                    }
                )
            }
        }
    }

    private func submitTip() {
        let text = content.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else {
            alertMessage = "يرجى كتابة تفاصيل المشاهدة"
            showAlert = true
            return
        }
        
        isSubmitting = true
        Task {
            do {
                let msg = try await APIService.shared.submitTip(
                    noticeCode: noticeCode,
                    content: text,
                    location: locationDescription,
                    phone: isAnonymous ? "مجهول" : contactPhone
                )
                await MainActor.run {
                    self.alertMessage = msg
                    self.isSuccess = true
                    self.showAlert = true
                    self.isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = error.localizedDescription
                    self.isSuccess = false
                    self.showAlert = true
                    self.isSubmitting = false
                }
            }
        }
    }
}
