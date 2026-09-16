//
//  SplashScreenView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Splash Intro matching Android SplashScreen
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive: Bool = false
    @State private var logoScale: CGFloat = 0.8
    @State private var opacity: Double = 0.4

    var body: some View {
        if isActive {
            MainTabView()
                .environment(\.layoutDirection, .rightToLeft)
        } else {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AinTheme.cyan.opacity(0.12))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.crop.circle.badge.questionmark.fill")
                            .font(.system(size: 64))
                            .foregroundColor(AinTheme.cyan)
                    }
                    .scaleEffect(logoScale)
                    
                    VStack(spacing: 6) {
                        Text("مـنـصـة أيــن هــم")
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(AinTheme.textPrimary)
                        
                        Text("المنظومة الوطنية الموحدة للبحث عن المفقودين")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AinTheme.textSecondary)
                    }
                    .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    logoScale = 1.0
                    opacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}
