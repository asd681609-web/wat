//
//  WhyAinHumView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — About Screen matching Android WhyAinHumScreen
//

import SwiftUI

struct WhyAinHumView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header Logo
                        VStack(spacing: 8) {
                            Circle()
                                .fill(AinTheme.cyan.opacity(0.12))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "person.crop.circle.badge.questionmark.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(AinTheme.cyan)
                                )
                            Text("منصة «أين هم» الوطنية")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(AinTheme.textPrimary)
                            Text("المنظومة الرقمية الموحدة للبحث عن المفقودين في ليبيا")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AinTheme.textSecondary)
                        }
                        .padding(.top, 16)
                        
                        // Mission Card
                        infoCard(
                            title: "رسالتنا الإنسانية",
                            content: "تسخير أحدث التقنيات الرقمية والذكاء الاصطناعي وشبكات المتطوعين لتقليص زمن الاستجابة في حوادث الفقدان والكوارث، ولمّ شمل العائلات بأبنائها وذويها بأعلى معايير الخصوصية والأمان.",
                            icon: "heart.fill",
                            iconColor: AinTheme.red
                        )
                        
                        // Hotline Card
                        HStack(spacing: 14) {
                            Circle()
                                .fill(AinTheme.red.opacity(0.12))
                                .frame(width: 46, height: 46)
                                .overlay(Image(systemName: "phone.fill").foregroundColor(AinTheme.red))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("الرقم الوطني الموحد للطوارئ")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                Text("اتصل على الرقم المجاني 1515 للتبليغ الفوري على مدار 24 ساعة")
                                    .font(.system(size: 11))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.red.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 16)
                        
                        // Strategic Partners
                        infoCard(
                            title: "التكامل الحكومي والأمني",
                            content: "تعمل المنصة بالتنسيق المباشر مع جهاز المباحث الجنائية، الهلال الأحمر الليبي، وزارة الصحة، والمنافذ الحدودية لضمان سرعة التعميم وتطويق حالات الاختفاء في الساعات الذهبية الأولى.",
                            icon: "shield.checkered",
                            iconColor: AinTheme.emerald
                        )
                        
                        Spacer().frame(height: 30)
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

    private func infoCard(title: String, content: String, icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AinTheme.textPrimary)
            }
            Text(content)
                .font(.system(size: 13))
                .foregroundColor(AinTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(AinTheme.bgSecondary)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
        .padding(.horizontal, 16)
    }
}
