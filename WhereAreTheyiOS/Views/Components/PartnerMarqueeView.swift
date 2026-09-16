//
//  PartnerMarqueeView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Partner Marquee Row matching Android
//

import SwiftUI

struct PartnerMarqueeView: View {
    let partners: [PartnerEntity] = PartnerEntity.defaultPartners

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("الجهات والشركاء الرسميون")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AinTheme.textSecondary)
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AinTheme.cyan)
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(partners) { partner in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(AinTheme.cyanSurface)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Image(systemName: "shield.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(AinTheme.cyan)
                                )
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(partner.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AinTheme.textPrimary)
                                if let category = partner.category {
                                    Text(category)
                                        .font(.system(size: 9))
                                        .foregroundColor(AinTheme.textMuted)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AinTheme.bgSecondary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AinTheme.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
