//
//  AmberAlertModalView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Full AMBER Alert Emergency Dialog matching Android AmberAlertDialog.kt
//

import SwiftUI
import AudioToolbox

struct AmberAlertModalView: View {
    let alert: AmberAlert
    let onDismiss: () -> Void
    let onViewDetails: (String) -> Void

    @State private var remainingSeconds: Int = 3600 // 60 minutes
    @State private var isRedPhase: Bool = true
    @State private var sirenScale: CGFloat = 0.9
    @State private var auraScale: CGFloat = 0.95
    @State private var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State private var countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // Dark Blur Background
            Color.black.opacity(0.85).ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Radar Pulse Aura Ring
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    RadialGradient(
                        colors: [isRedPhase ? AinTheme.sirenRed.opacity(0.35) : AinTheme.sirenBlue.opacity(0.35), Color.clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(maxWidth: 360, maxHeight: 440)
                .scaleEffect(auraScale)

            // Alert Dialog Container
            VStack(spacing: 16) {
                // 🚨 Police Siren Lightbar Header
                HStack {
                    // Left Red Strobe
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isRedPhase ? AinTheme.sirenRed : Color(hex: "450A0A"))
                            .frame(width: 10, height: 10)
                            .shadow(color: isRedPhase ? AinTheme.sirenRed : .clear, radius: 6)
                        Circle()
                            .fill(AinTheme.sirenRed.opacity(0.6))
                            .frame(width: 6, height: 6)
                    }

                    Spacer()

                    // Center Badge
                    HStack(spacing: 6) {
                        Text("🚨")
                            .font(.system(size: 18))
                            .scaleEffect(sirenScale)
                        Text("تنبيه طوارئ AMBER")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                            .tracking(0.5)
                    }

                    Spacer()

                    // Right Blue Strobe
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AinTheme.sirenBlue.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(!isRedPhase ? AinTheme.sirenBlue : Color(hex: "172554"))
                            .frame(width: 10, height: 10)
                            .shadow(color: !isRedPhase ? AinTheme.sirenBlue : .clear, radius: 6)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [AinTheme.sirenRed.opacity(0.25), Color(hex: "0F172A"), AinTheme.sirenBlue.opacity(0.25)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(isRedPhase ? AinTheme.sirenRed.opacity(0.5) : AinTheme.sirenBlue.opacity(0.5), lineWidth: 1)
                )

                // Countdown Timer Pill
                HStack(spacing: 6) {
                    Text("⏱️")
                        .font(.system(size: 12))
                    Text("توقف السارينة تلقائياً خلال: ")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "94A3B8"))
                    Text("\(formattedTime) دقيقة")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(Color(hex: "F59E0B").opacity(0.12))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "F59E0B").opacity(0.4), lineWidth: 1))

                // Headline
                Text("عاجل من غرفة العمليات المركزية")
                    .font(.system(size: 17, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Missing Person Photo (if available)
                if let photoUrl = alert.photoUrl, !photoUrl.isEmpty, let url = URL(string: photoUrl.starts(with: "http") ? photoUrl : "https://wat.org.ly/" + photoUrl) {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: 160)
                                    .clipped()
                                    .cornerRadius(16)
                            default:
                                Color.gray.opacity(0.2).frame(height: 140).cornerRadius(16)
                            }
                        }
                        
                        Text("🔴 صورة حالة الاختفاء")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "FCA5A5"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(10)
                            .padding(8)
                    }
                }

                // Alert Message Body Card
                Text(alert.message)
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .foregroundColor(Color(hex: "E2E8F0"))
                    .multilineTextAlignment(.center)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "0F172A"))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))

                // Action Buttons
                HStack(spacing: 10) {
                    Button(action: {
                        onViewDetails(alert.uniqueCode)
                        onDismiss()
                    }) {
                        HStack(spacing: 6) {
                            Text("📡")
                            Text("عرض ملف البلاغ")
                                .font(.system(size: 13, weight: .black))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [AinTheme.blue, Color(hex: "1D4ED8")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(14)
                    }

                    Button(action: onDismiss) {
                        Text("✕ إغلاق التنبيه")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "CBD5E1"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                }
            }
            .padding(20)
            .background(Color(hex: "070D1E"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                isRedPhase ? AinTheme.sirenRed : AinTheme.sirenBlue,
                                (isRedPhase ? AinTheme.sirenRed : AinTheme.sirenBlue).opacity(0.35),
                                Color(hex: "F59E0B")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: isRedPhase ? AinTheme.sirenRed.opacity(0.5) : AinTheme.sirenBlue.opacity(0.5), radius: 24)
            .padding(.horizontal, 20)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.45)) {
                isRedPhase.toggle()
                sirenScale = (sirenScale == 0.9) ? 1.2 : 0.9
                auraScale = (auraScale == 0.95) ? 1.06 : 0.95
            }
            // Trigger emergency haptic vibration pulse
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        .onReceive(countdownTimer) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                onDismiss()
            }
        }
        .onAppear {
            // Play system emergency alert chime sound
            AudioServicesPlaySystemSound(1005)
        }
    }
}
