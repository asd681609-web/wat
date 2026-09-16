//
//  MedicalScannerView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Medical Scanner matching Android MedicalScannerScreen
//

import SwiftUI

struct MedicalScannerView: View {
    let onNoticeClick: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchCode: String = ""
    @State private var isScanning: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Scanner Frame Simulation
                    VStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AinTheme.cyan, style: StrokeStyle(lineWidth: 3, dash: [10]))
                                .frame(width: 260, height: 260)
                                .background(Color.black.opacity(0.03))
                            
                            VStack(spacing: 12) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 80))
                                    .foregroundColor(AinTheme.cyan)
                                
                                Text("وجّه الكاميرا نحو الباركود أو الرمز الميداني")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 30)
                    
                    // Medical Unit Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(AinTheme.red)
                            Text("وحدة الفحص الطبي ومطابقة المجهولين")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AinTheme.textPrimary)
                        }
                        
                        Text("هذه الوحدة مخصصة للمستشفيات، مراكز الإسعاف، والطب الشرعي لمطابقة الحالات الفاقدة للوعي أو المتوفين مجهولي الهوية مع البلاغات النشطة.")
                            .font(.system(size: 12))
                            .foregroundColor(AinTheme.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(AinTheme.bgSecondary)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") { dismiss() }
                        .foregroundColor(AinTheme.textMuted)
                }
                ToolbarItem(placement: .principal) {
                    Text("الماسح الطبي الميداني")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
            }
        }
    }
}
