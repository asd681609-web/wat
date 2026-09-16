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

    @State private var remainingSeconds: Int = 3600 // 60 minutes countdown
    @State private var isRedPhase: Bool = true
    @State private var sirenScale: CGFloat = 0.92
    @State private var auraScale: CGFloat = 0.95
    @State private var timer = Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()
    @State private var countdownTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // Dark Backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture {
                    handleDismiss()
                }

            // Radar Pulse Aura Ring (Animated Red & Blue)
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    RadialGradient(
                        colors: [
                            (isRedPhase ? Color(hex: "EF4444") : Color(hex: "3B82F6")).opacity(0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 220
                    )
                )
                .frame(maxWidth: 360, maxHeight: 460)
                .scaleEffect(auraScale)

            // Alert Dialog Container
            VStack(spacing: 16) {
                // 🚨 Police Siren Lightbar Header (Red & Blue Strobe LEDs)
                HStack {
                    // Left Red Strobe
                    HStack(spacing: 4) {
                        Circle()
                            .fill(isRedPhase ? Color(hex: "EF4444") : Color(hex: "450A0A"))
                            .frame(width: 10, height: 10)
                            .shadow(color: isRedPhase ? Color(hex: "EF4444") : .clear, radius: 6)
                        Circle()
                            .fill(Color(hex: "EF4444").opacity(0.6))
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
                            .fill(Color(hex: "3B82F6").opacity(0.6))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(!isRedPhase ? Color(hex: "3B82F6") : Color(hex: "172554"))
                            .frame(width: 10, height: 10)
                            .shadow(color: !isRedPhase ? Color(hex: "3B82F6") : .clear, radius: 6)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "EF4444").opacity(0.25), Color(hex: "0F172A"), Color(hex: "3B82F6").opacity(0.25)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(50)
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(isRedPhase ? Color(hex: "EF4444").opacity(0.6) : Color(hex: "3B82F6").opacity(0.6), lineWidth: 1)
                )

                // Flashlight & Audio Strobe Indicator Pill
                HStack(spacing: 6) {
                    Text("⚡")
                        .font(.system(size: 12))
                    Text("وميض فلاش الطوارئ وصفارة الإنذار قيد التشغيل")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "FDE047"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(hex: "CA8A04").opacity(0.2))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "EAB308").opacity(0.4), lineWidth: 1))

                // Auto-stop countdown timer
                HStack(spacing: 6) {
                    Text("⏱️")
                        .font(.system(size: 11))
                    Text("توقف الإنذار تلقائياً خلال: ")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "94A3B8"))
                    Text("\(formattedTime) دقيقة")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Color(hex: "F59E0B"))
                }

                // Headline
                Text("عاجل من غرفة العمليات المركزية")
                    .font(.system(size: 16, weight: .black))
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
                            .background(Color.black.opacity(0.85))
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
                        handleDismiss()
                        onViewDetails(alert.uniqueCode)
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
                            LinearGradient(colors: [Color(hex: "0284C7"), Color(hex: "1D4ED8")], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(14)
                    }

                    Button(action: {
                        handleDismiss()
                    }) {
                        Text("✕ إيقاف السارينة")
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
                                isRedPhase ? Color(hex: "EF4444") : Color(hex: "3B82F6"),
                                (isRedPhase ? Color(hex: "EF4444") : Color(hex: "3B82F6")).opacity(0.35),
                                Color(hex: "F59E0B")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: isRedPhase ? Color(hex: "EF4444").opacity(0.5) : Color(hex: "3B82F6").opacity(0.5), radius: 24)
            .padding(.horizontal, 20)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.45)) {
                isRedPhase.toggle()
                sirenScale = (sirenScale == 0.92) ? 1.2 : 0.92
                auraScale = (auraScale == 0.95) ? 1.06 : 0.95
            }
        }
        .onReceive(countdownTimer) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                handleDismiss()
            }
        }
        .onAppear {
            // Start emergency siren audio + camera flashlight strobe + vibration
            EmergencyAlertController.shared.startEmergencyAlerts()
        }
        .onDisappear {
            EmergencyAlertController.shared.stopAllAlerts()
        }
    }

    private func handleDismiss() {
        EmergencyAlertController.shared.stopAllAlerts()
        onDismiss()
    }
}
