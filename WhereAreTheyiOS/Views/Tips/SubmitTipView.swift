//
//  SubmitTipView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct SubmitTipView: View {
    let noticeCode: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var content: String = ""
    @State private var location: String = ""
    @State private var phone: String = ""
    @State private var isAnonymous: Bool = false
    
    @State private var isSubmitting: Bool = false
    @State private var alertMessage: String? = nil
    @State private var isSuccess: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.06, blue: 0.12).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .trailing, spacing: 18) {
                        
                        // Header info banner
                        HStack {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("معلوماتك محمية بكامل السرية")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                Text("يمكنك التبليغ عن مشاهدة بشكل مجهول")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "shield.checkmark.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.blue)
                        }
                        .padding(14)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.3), lineWidth: 1))
                        
                        // Tip Content Text Editor
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("وصف المشاهدة / التفاصيل *")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            
                            TextEditor(text: $content)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .environment(\.layoutDirection, .rightToLeft)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        }
                        
                        // Location Description
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("مكان المشاهدة (المدينة / الحي)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            
                            TextField("مثال: طرابلس - بالقرب من المستشفى...", text: $location)
                                .padding(12)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        }
                        
                        // Anonymous Toggle
                        Toggle(isOn: $isAnonymous) {
                            HStack {
                                Spacer()
                                Text("إرسال الإفادة بشكل مجهول (بدون بيانات شخصية)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .tint(.red)
                        .padding(.vertical, 4)
                        
                        // Phone input (if not anonymous)
                        if !isAnonymous {
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("رقم الهاتف للتواصل")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                
                                TextField("091XXXXXXX", text: $phone)
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .keyboardType(.phonePad)
                                    .multilineTextAlignment(.trailing)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
                            }
                        }
                        
                        // Submit Button
                        Button(action: submitTip) {
                            HStack {
                                Spacer()
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("إرسال الإفادة الميدانية")
                                        .font(.system(size: 16, weight: .bold))
                                    Image(systemName: "paperplane.fill")
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.red, Color(red: 0.7, green: 0.1, blue: 0.1)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isSubmitting || content.isEmpty)
                        .opacity(content.isEmpty ? 0.6 : 1.0)
                        .padding(.top, 10)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("إفادة ميدانية - #\(noticeCode)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
            .alert(isPresented: .constant(alertMessage != nil)) {
                Alert(
                    title: Text(isSuccess ? "تم بنجاح" : "تنبيه"),
                    message: Text(alertMessage ?? ""),
                    dismissButton: .default(Text("حسناً")) {
                        if isSuccess { dismiss() }
                        alertMessage = nil
                    }
                )
            }
        }
    }
    
    private func submitTip() {
        isSubmitting = true
        Task {
            do {
                let msg = try await APIService.shared.submitTip(
                    noticeCode: noticeCode,
                    content: content,
                    location: location,
                    phone: isAnonymous ? "مجهول" : phone
                )
                await MainActor.run {
                    isSubmitting = false
                    isSuccess = true
                    alertMessage = msg
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    isSuccess = false
                    alertMessage = error.localizedDescription
                }
            }
        }
    }
}
