//
//  WhereAreTheyApp.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Main App Entry matching Android
//

import SwiftUI

@main
struct WhereAreTheyApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light)
                .environment(\.layoutDirection, .rightToLeft) // Default Arabic RTL
        }
    }
}
