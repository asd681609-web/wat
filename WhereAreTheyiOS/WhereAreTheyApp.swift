//
//  WhereAreTheyApp.swift
//  WhereAreTheyiOS
//

import SwiftUI

@main
struct WhereAreTheyApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .environment(\.layoutDirection, .rightToLeft) // Default Arabic RTL
        }
    }
}
