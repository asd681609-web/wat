//
//  ModernNoticeCardView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Modern Card matching Android ModernNoticeCard
//

import SwiftUI

struct ModernNoticeCardView: View {
    let notice: Notice
    let onCardClick: () -> Void
    
    @State private var isPulsing: Bool = false
    
    private var statusColor: Color {
        if notice.isDeceased { return AinTheme.textMuted }
        if notice.isResolved { return AinTheme.emerald }
        if notice.isMissing { return AinTheme.red }
        return AinTheme.emerald
    }
    
    private var statusTitle: String {
        if notice.isDeceased { return "متوفى مجهول" }
        if notice.isResolved { return "تم العثور عليه" }
        if notice.isMissing { return "مفقود" }
        return "معثور عليه"
    }

    var body: some View {
        Button(action: onCardClick) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    // Photo Box
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AinTheme.bgTertiary)
                            .frame(width: 80, height: 80)
                        
                        if let photoURL = notice.fullPhotoURL {
                            AsyncImage(url: photoURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().tint(AinTheme.cyan)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(16)
                                case .failure:
                                    Image(systemName: "person.crop.square.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(AinTheme.textMuted)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.crop.square.fill")
                                .font(.system(size: 36))
                                .foregroundColor(AinTheme.textMuted)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(statusColor.opacity(0.3), lineWidth: 1.5)
                    )
                    
                    // Info Column
                    VStack(alignment: .leading, spacing: 6) {
                        // Status Badge + Days Since
                        HStack {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 7, height: 7)
                                    .scaleEffect(isPulsing ? 1.3 : 0.9)
                                Text(statusTitle)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(statusColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(statusColor.opacity(0.12))
                            .cornerRadius(8)
                            
                            Spacer()
                            
                            if let days = notice.daysSince, days > 0 {
                                Text("منذ \(days) يوم")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(AinTheme.textMuted)
                            }
                        }
                        
                        // Full Name / Code
                        Text(notice.displayName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AinTheme.textPrimary)
                            .lineLimit(1)
                        
                        // Age & City & District
                        HStack(spacing: 8) {
                            if let age = notice.ageEstimate, age > 0 {
                                Label("\(age) سنة", systemImage: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                            
                            if let city = notice.city, !city.isEmpty {
                                Label(city, systemImage: "mappin.and.ellipse")
                                    .font(.system(size: 12))
                                    .foregroundColor(AinTheme.textSecondary)
                            }
                        }
                    }
                }
                
                // Urgent Medical Badge if needed
                if notice.urgentMedicationRequired == 1 || notice.specialNeeds?.isEmpty == false {
                    HStack(spacing: 6) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 11))
                        Text(notice.medicationName ?? notice.specialNeeds ?? "حالة طبية تتطلب علاجاً عاجلاً")
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                    }
                    .foregroundColor(AinTheme.redDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AinTheme.redSurface)
                    .cornerRadius(8)
                }
            }
            .padding(14)
            .background(AinTheme.bgSecondary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        notice.isMissing ?
                        LinearGradient(colors: [AinTheme.red.opacity(0.6), AinTheme.amber.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [AinTheme.emerald.opacity(0.6), AinTheme.cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
