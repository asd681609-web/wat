//
//  WhereAreTheyApp.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Main App Entry matching Android
//

import SwiftUI

@main
struct WhereAreTheyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var amberSync = AmberAlertSyncManager.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light)
                .environment(\.layoutDirection, .rightToLeft) // Default Arabic RTL
                .onAppear {
                    notificationManager.requestNotificationPermission()
                    amberSync.startSync()
                    BackgroundKeepAliveManager.shared.startKeepAlive()
                }
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .background:
                        BackgroundKeepAliveManager.shared.startKeepAlive()
                    case .active:
                        break
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}
