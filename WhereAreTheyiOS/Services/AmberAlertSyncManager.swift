//
//  AmberAlertSyncManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (Ø£ÙŠÙ† Ù‡Ù…) â€” Live Real-Time AMBER Alert Sync & Polling Engine
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AmberAlertSyncManager: ObservableObject {
    static let shared = AmberAlertSyncManager()

    @Published var activeAlerts: [AmberAlert] = []
    @Published var currentActiveAlert: AmberAlert? = nil
    @Published var isEmergencyActive: Bool = false
    @Published var lastSyncDate: Date? = nil

    private var pollTimer: Timer?
    private let seenKey = "AinHum_Seen_Amber_Alert_IDs"
    
    private var seenAlertIds: Set<Int> {
        get {
            let arr = UserDefaults.standard.array(forKey: seenKey) as? [Int] ?? []
            return Set(arr)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: seenKey)
        }
    }

    private init() {
        startSync()
    }

    func startSync() {
        pollTimer?.invalidate()
        Task {
            await syncAmberAlerts(triggerPopupOnNew: true)
        }
        
        // Poll every 25 seconds while app is running
        pollTimer = Timer.scheduledTimer(withTimeInterval: 25.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                await self.syncAmberAlerts(triggerPopupOnNew: true)
            }
        }
    }

    func stopSync() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    func syncAmberAlerts(triggerPopupOnNew: Bool = true) async {
        do {
            let fetchedAlerts = try await APIService.shared.fetchAmberAlerts()
            self.activeAlerts = fetchedAlerts
            self.lastSyncDate = Date()

            guard !fetchedAlerts.isEmpty else {
                return
            }

            var currentSeen = self.seenAlertIds
            var newlyDetected: AmberAlert? = nil

            for alert in fetchedAlerts {
                if !currentSeen.contains(alert.id) {
                    newlyDetected = alert
                    currentSeen.insert(alert.id)
                    break
                }
            }

            if let newAlert = newlyDetected, triggerPopupOnNew {
                self.seenAlertIds = currentSeen
                self.triggerEmergencyAlert(alert: newAlert)
            } else if self.currentActiveAlert == nil && triggerPopupOnNew && self.seenAlertIds.isEmpty {
                if let firstAlert = fetchedAlerts.first {
                    self.seenAlertIds.insert(firstAlert.id)
                    self.triggerEmergencyAlert(alert: firstAlert)
                }
            }
        } catch {
            print("âš ï¸ AmberAlertSyncManager sync error: \(error.localizedDescription)")
        }
    }

    func triggerEmergencyAlert(alert: AmberAlert) {
        self.currentActiveAlert = alert
        self.isEmergencyActive = true

        // 1. Play real siren sound (amber_alert_siren.wav) + camera flashlight strobe + vibration
        EmergencyAlertController.shared.startEmergencyAlerts()

        // 2. Schedule system lockscreen/tray notification with amber_alert_siren.wav sound
        NotificationManager.shared.scheduleLocalAmberAlertNotification(alert: alert)
    }

    func dismissCurrentAlert() {
        withAnimation {
            self.currentActiveAlert = nil
            self.isEmergencyActive = false
        }
        // Stop siren, flashlight, vibration
        EmergencyAlertController.shared.stopAllAlerts()
    }

    func showSpecificAlert(_ alert: AmberAlert) {
        withAnimation {
            self.currentActiveAlert = alert
            self.isEmergencyActive = true
        }
        EmergencyAlertController.shared.startEmergencyAlerts()
    }

    func testSirenAlert() {
        let sample = AmberAlert(
            id: 99999,
            noticeId: nil,
            message: "ðŸš¨ ØªØ¬Ø±Ø¨Ø© ØµÙØ§Ø±Ø© Ø§Ù„Ø¥Ù†Ø°Ø§Ø± ÙˆÙˆÙ…ÙŠØ¶ Ø§Ù„ÙÙ„Ø§Ø´: ØªÙ†Ø¨ÙŠÙ‡ Ø·ÙˆØ§Ø±Ø¦ AMBER Ù…Ù† ØºØ±ÙØ© Ø§Ù„Ø¹Ù…Ù„ÙŠØ§Øª Ø§Ù„Ù…Ø±ÙƒØ²ÙŠØ© â€” Ø§Ù„Ù†Ø¸Ø§Ù… ÙŠØ¹Ù…Ù„ ÙˆÙ…Ø³ØªØ¹Ø¯ Ù„Ø§Ø³ØªÙ‚Ø¨Ø§Ù„ Ø§Ù„Ø¨Ù„Ø§ØºØ§Øª Ø§Ù„Ø­ÙŠØ©.",
            coverageCity: "Ø·Ø±Ø§Ø¨Ù„Ø³",
            radiusKm: 15,
            uniqueCode: "AIN-TEST-2026",
            fullName: "Ø­Ø§Ù„Ø© ØªØ¬Ø±ÙŠØ¨ÙŠØ© Ù„Ø§Ø®ØªØ¨Ø§Ø± Ø§Ù„ØµÙˆØª ÙˆØ§Ù„ÙÙ„Ø§Ø´ ÙˆØ§Ù„Ø´Ø§Ø´Ø©",
            gender: "male",
            ageEstimate: "25",
            noticeCity: "Ø·Ø±Ø§Ø¨Ù„Ø³",
            photoUrl: nil,
            issuedAt: "Ø§Ù„Ø¢Ù†"
        )
        self.triggerEmergencyAlert(alert: sample)
    }
}