//
//  AmberAlertBannerView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Flashing AMBER Siren Banner matching Android
//

import SwiftUI

struct AmberAlertBannerView: View {
    let alerts: [AmberAlert]
    let onAlertClick: (AmberAlert) -> Void
    
    @State private var isDismissed: Bool = false
    @State private var isRedPhase: Bool = true
    @State private var timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if let firstAlert = alerts.first, !isDismissed {
            Button(action: {
                withAnimation { isDismissed = true }
                onAlertClick(firstAlert)
            }) {
                HStack(spacing: 12) {
                    // Pulsing Siren Icon Box
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 42, height: 42)
                        Text("🚨")
                            .font(.system(size: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("تنبيه طوارئ عاجل — AMBER Alert")
                                .font(.system(size: 13, weight: .black))
                                .foregroundColor(.white)
                            Spacer()
                            Text(firstAlert.coverageCity)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(6)
                                .foregroundColor(.white)
                        }
                        
                        Text(firstAlert.message)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.95))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(14)
                .background(
                    LinearGradient(
                        colors: isRedPhase ? [AinTheme.sirenRed, AinTheme.redDark] : [AinTheme.sirenBlue, AinTheme.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(
                    color: isRedPhase ? AinTheme.sirenRedGlow : AinTheme.sirenBlueGlow,
                    radius: 8, x: 0, y: 4
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    isRedPhase.toggle()
                }
            }
        }
    }
}
