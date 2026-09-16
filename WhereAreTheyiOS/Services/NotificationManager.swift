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
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
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

        let city = "طرابلس" // Default or detected city
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
                print("✅ iOS Device successfully registered to AinHum central notification server")
            } catch {
                print("⚠️ Failed to register device token with backend: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Schedule Real Emergency AMBER Alert System Notification
    func scheduleLocalAmberAlertNotification(alert: AmberAlert) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 تنبيه طوارئ AMBER — أين هم (\(alert.coverageCity))"
        content.subtitle = alert.fullName ?? "حالة طوارئ حرجة"
        content.body = alert.message
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.userInfo = [
            "unique_code": alert.uniqueCode,
            "alert_id": alert.id,
            "notice_id": alert.noticeId ?? 0
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "amber_alert_\(alert.id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to add AMBER notification to system center: \(error.localizedDescription)")
            } else {
                print("🚨 System Emergency Notification dispatched to lockscreen & Dynamic Island")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate
    // Present banner, sound and badge even when app is active in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
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
        let userInfo = response.notification.request.content.userInfo
        if let code = userInfo["unique_code"] as? String {
            print("User tapped emergency notification for notice: \(code)")
            // Notification response handled by app router
        }
        completionHandler()
    }
}