//
//  ReportView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Submission Form matching Android ReportScreen
//

import SwiftUI

struct ReportView: View {
    let type: String // "missing" or "found"
    @Environment(\.dismiss) private var dismiss
    
    // Form fields
    @State private var fullName: String = ""
    @State private var age: String = ""
    @State private var city: String = "طرابلس"
    @State private var district: String = ""
    @State private var contactPhone: String = ""
    @State private var description: String = ""
    @State private var specialNeeds: String = ""
    @State private var urgentMedication: Bool = false
    
    @State private var isSubmitting: Bool = false
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var submitSuccess: Bool = false

    let cities = ["طرابلس", "بنغازي", "مصراتة", "الزاوية", "سبها", "سرت", "البيضاء", "طبرق", "زليتن", "درنة", "غريان", "الخمس"]

    var isMissing: Bool { type == "missing" }

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Notice Type Card Banner
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(isMissing ? AinTheme.red.opacity(0.15) : AinTheme.cyan.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: isMissing ? "exclamationmark.triangle.fill" : "person.crop.circle.badge.checkmark")
                                    .font(.system(size: 20))
                                    .foregroundColor(isMissing ? AinTheme.red : AinTheme.cyan)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isMissing ? "نموذج الإبلاغ عن مفقود جديد" : "نموذج الإبلاغ عن معثور عليه")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                Text("يتم فحص وتعميم البلاغ فوراً على الجهات الأمنية والميدانية")
                                    .font(.system(size: 11))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                        
                        // Personal Info Fields
                        VStack(alignment: .leading, spacing: 12) {
                            Text("البيانات الأساسية")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AinTheme.textSecondary)
                            
                            customTextField(title: isMissing ? "الاسم الرباعي للمفقود *" : "اسم الشخص المعثور عليه (إن وجد)", text: $fullName)
                            
                            HStack(spacing: 12) {
                                customTextField(title: "العمر التقريبي *", text: $age, keyboardType: .numberPad)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("المدينة *")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(AinTheme.textSecondary)
                                    Menu {
                                        ForEach(cities, id: \.self) { c in
                                            Button(c) { self.city = c }
                                        }
                                    } label: {
                                        HStack {
                                            Text(city)
                                                .font(.system(size: 13))
                                                .foregroundColor(AinTheme.textPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 11))
                                                .foregroundColor(AinTheme.textMuted)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                        .background(AinTheme.bgTertiary)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            
                            customTextField(title: "المنطقة أو الحي السكني *", text: $district)
                            customTextField(title: "رقم هاتف ولي الأمر أو المُبلّغ *", text: $contactPhone, keyboardType: .phonePad)
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                        
                        // Medical & Special Needs
                        VStack(alignment: .leading, spacing: 12) {
                            Text("الحالة الصحية والاحتياجات الطبية")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AinTheme.textSecondary)
                            
                            Toggle(isOn: $urgentMedication) {
                                Text("يتناول أدوية حرجة أو يعاني من مرض مزمن")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AinTheme.textPrimary)
                            }
                            .tint(AinTheme.red)
                            
                            if urgentMedication {
                                customTextField(title: "اسم الدواء أو الحالة الطبية بالتفصيل", text: $specialNeeds)
                            }
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 12) {
                            Text("أوصاف إضافية وتفاصيل الواقعة")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AinTheme.textSecondary)
                            
                            TextEditor(text: $description)
                                .frame(height: 90)
                                .padding(8)
                                .background(AinTheme.bgTertiary)
                                .cornerRadius(10)
                                .overlay(
                                    VStack {
                                        if description.isEmpty {
                                            HStack {
                                                Text("اكتب أي علامات مميزة، أوصاف الملابس، أو آخر تفاصيل...")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AinTheme.textMuted)
                                                    .padding(12)
                                                Spacer()
                                            }
                                        }
                                        Spacer()
                                    }
                                )
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                        
                        // Submit Button
                        Button(action: submitNotice) {
                            HStack(spacing: 8) {
                                if isSubmitting {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("إرسال واعتماد البلاغ")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isMissing ? AinTheme.red : AinTheme.cyan)
                            .cornerRadius(14)
                            .shadow(color: (isMissing ? AinTheme.red : AinTheme.cyan).opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .disabled(isSubmitting)
                        
                        Spacer().frame(height: 30)
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
                    Text(isMissing ? "إبلاغ عن مفقود" : "إبلاغ عن معثور عليه")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(submitSuccess ? "تم بنجاح" : "تنبيه"),
                    message: Text(alertMessage ?? ""),
                    dismissButton: .default(Text("حسناً")) {
                        if submitSuccess { dismiss() }
                    }
                )
            }
        }
    }

    private func customTextField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AinTheme.textSecondary)
            TextField("", text: text)
                .font(.system(size: 13))
                .keyboardType(keyboardType)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AinTheme.bgTertiary)
                .cornerRadius(10)
        }
    }

    private func submitNotice() {
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty && isMissing {
            alertMessage = "يرجى كتابة اسم المفقود"
            showAlert = true
            return
        }
        if contactPhone.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "يرجى كتابة رقم الهاتف للتواصل"
            showAlert = true
            return
        }

        isSubmitting = true
        Task {
            do {
                let msg = try await APIService.shared.submitReport(
                    type: type,
                    fullName: fullName,
                    age: age,
                    city: city,
                    district: district,
                    description: description,
                    contactPhone: contactPhone,
                    specialNeeds: urgentMedication ? specialNeeds : nil
                )
                await MainActor.run {
                    self.alertMessage = msg
                    self.submitSuccess = true
                    self.showAlert = true
                    self.isSubmitting = false
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = error.localizedDescription
                    self.submitSuccess = false
                    self.showAlert = true
                    self.isSubmitting = false
                }
            }
        }
    }
}
