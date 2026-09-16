//
//  NotificationManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Real-Time Push & System Emergency Notification Engine
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

        let city = "طرابلس"
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
                print("✅ iOS Device registered in AinHum device_tokens table")
            } catch {
                print("⚠️ Failed to register device token: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Real Emergency AMBER Alert System Notification
    func scheduleLocalAmberAlertNotification(alert: AmberAlert, delaySeconds: TimeInterval = 0.5) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 تنبيه طوارئ AMBER — أين هم (\(alert.coverageCity))"
        content.subtitle = alert.fullName ?? "حالة اختفاء حرجة"
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
                print("⚠️ Failed to add AMBER notification: \(error.localizedDescription)")
            } else {
                print("🚨 AMBER notification scheduled (delay: \(delaySeconds)s) with amber_alert_siren.wav")
            }
        }
    }

    // MARK: - Test Lock Screen Notification (User can lock phone to test!)
    func scheduleLockscreenTest(delaySeconds: TimeInterval = 5.0) {
        let sample = AmberAlert(
            id: Int.random(in: 10000...99999),
            noticeId: 18,
            message: "🚨 تجربة قفل الشاشة: تنبيه طوارئ AMBER مع السارينة ووميض الفلاش! النظام يعمل ومستعد لاستقبال البلاغات الحية.",
            coverageCity: "طرابلس",
            radiusKm: 15,
            uniqueCode: "AIN-TEST-LOCK",
            fullName: "اختبار الطوارئ وشاشة القفل",
            gender: "female",
            ageEstimate: "25",
            noticeCity: "طرابلس",
            photoUrl: nil,
            issuedAt: "الآن"
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
