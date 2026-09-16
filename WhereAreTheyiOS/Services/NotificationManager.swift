//
//  NotificationManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (Ø£ÙŠÙ† Ù‡Ù…) â€” Real-Time Push & System Emergency Notification Engine
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isPermissionGranted: Bool = false
    @Published var deviceTokenString: String? = nil

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkCurrentPermission()
    }

    func checkCurrentPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }

    func requestNotificationPermission() {
        var options: UNAuthorizationOptions = [.alert, .badge, .sound]
        if #available(iOS 15.0, *) {
            options.insert(.timeSensitive)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.registerDeviceWithBackend()
                }
            }
        }
    }

    func registerDeviceWithBackend(token: String? = nil) {
        let identifier = token ?? deviceTokenString ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        self.deviceTokenString = identifier

        let city = "Ø·Ø±Ø§Ø¨Ù„Ø³"
        let lat = LocationManager.shared.userLocation?.latitude
        let lng = LocationManager.shared.userLocation?.longitude

        Task {
            do {
                try await APIService.shared.registerDevice(
                    fcmToken: identifier,
                    city: city,
                    lat: lat,
                    lng: lng,
                    deviceOs: "ios"
                )
                print("âœ… iOS Device registered in AinHum device_tokens table")
            } catch {
                print("âš ï¸ Failed to register device token: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Real Emergency AMBER Alert System Notification
    func scheduleLocalAmberAlertNotification(alert: AmberAlert, delaySeconds: TimeInterval = 0.5) {
        let content = UNMutableNotificationContent()
        content.title = "ðŸš¨ ØªÙ†Ø¨ÙŠÙ‡ Ø·ÙˆØ§Ø±Ø¦ AMBER â€” Ø£ÙŠÙ† Ù‡Ù… (\(alert.coverageCity))"
        content.subtitle = alert.fullName ?? "Ø­Ø§Ù„Ø© Ø§Ø®ØªÙØ§Ø¡ Ø­Ø±Ø¬Ø©"
        content.body = alert.message
        
        // Use the bundled amber_alert_siren.wav for the system notification sound
        content.sound = UNNotificationSound(named: UNNotificationSoundName("amber_alert_siren.wav"))
        content.badge = 1
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .timeSensitive
            content.relevanceScore = 1.0
        }
        
        content.userInfo = [
            "unique_code": alert.uniqueCode,
            "alert_id": alert.id,
            "notice_id": alert.noticeId ?? 0
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delaySeconds, 0.5), repeats: false)
        let request = UNNotificationRequest(identifier: "amber_alert_\(alert.id)_\(Int(Date().timeIntervalSince1970))", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("âš ï¸ Failed to add AMBER notification: \(error.localizedDescription)")
            } else {
                print("ðŸš¨ AMBER notification scheduled (delay: \(delaySeconds)s) with amber_alert_siren.wav")
            }
        }
    }

    // MARK: - Test Lock Screen Notification (User can lock phone to test!)
    func scheduleLockscreenTest(delaySeconds: TimeInterval = 5.0) {
        let sample = AmberAlert(
            id: Int.random(in: 10000...99999),
            noticeId: 18,
            message: "ðŸš¨ ØªØ¬Ø±Ø¨Ø© Ù‚ÙÙ„ Ø§Ù„Ø´Ø§Ø´Ø©: ØªÙ†Ø¨ÙŠÙ‡ Ø·ÙˆØ§Ø±Ø¦ AMBER Ù…Ø¹ Ø§Ù„Ø³Ø§Ø±ÙŠÙ†Ø© ÙˆÙˆÙ…ÙŠØ¶ Ø§Ù„ÙÙ„Ø§Ø´! Ø§Ù„Ù†Ø¸Ø§Ù… ÙŠØ¹Ù…Ù„ ÙˆÙ…Ø³ØªØ¹Ø¯ Ù„Ø§Ø³ØªÙ‚Ø¨Ø§Ù„ Ø§Ù„Ø¨Ù„Ø§ØºØ§Øª Ø§Ù„Ø­ÙŠØ©.",
            coverageCity: "Ø·Ø±Ø§Ø¨Ù„Ø³",
            radiusKm: 15,
            uniqueCode: "AIN-TEST-LOCK",
            fullName: "Ø§Ø®ØªØ¨Ø§Ø± Ø§Ù„Ø·ÙˆØ§Ø±Ø¦ ÙˆØ´Ø§Ø´Ø© Ø§Ù„Ù‚ÙÙ„",
            gender: "female",
            ageEstimate: "25",
            noticeCity: "Ø·Ø±Ø§Ø¨Ù„Ø³",
            photoUrl: nil,
            issuedAt: "Ø§Ù„Ø¢Ù†"
        )
        scheduleLocalAmberAlertNotification(alert: sample, delaySeconds: delaySeconds)
    }

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // When notification fires while app is in foreground, trigger the alert controller (sound + flash)
        EmergencyAlertController.shared.startEmergencyAlerts()
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Stop siren when user interacts with notification
        EmergencyAlertController.shared.stopAllAlerts()
        
        let userInfo = response.notification.request.content.userInfo
        if let alertId = userInfo["alert_id"] as? Int {
            print("User interacted with alert: \(alertId)")
        }
        completionHandler()
    }
}