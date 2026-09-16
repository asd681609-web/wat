//
//  EmergencyAlertController.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Central Emergency Controller (Siren, Flashlight & Vibration)
//  Matching Android EmergencyAlertController.kt
//

import Foundation
import UIKit

class EmergencyAlertController {
    static let shared = EmergencyAlertController()
    
    private let autoStopDelaySeconds: TimeInterval = 30.0 // Auto-stop after 30 seconds for safety
    private var autoStopTimer: Timer?
    private(set) var isRunning: Bool = false
    
    private init() {}
    
    func startEmergencyAlerts() {
        stopAllAlerts()
        isRunning = true
        
        // 1. Play emergency siren sound
        EmergencySoundManager.shared.playEmergencyAlarm()
        
        // 2. Start tactical camera flashlight strobe
        EmergencyFlashlightManager.shared.startStrobe()
        
        // 3. Schedule auto-stop timeout after 30 seconds
        autoStopTimer?.invalidate()
        autoStopTimer = Timer.scheduledTimer(withTimeInterval: autoStopDelaySeconds, repeats: false) { [weak self] _ in
            self?.stopAllAlerts()
        }
    }
    
    func stopAllAlerts() {
        autoStopTimer?.invalidate()
        autoStopTimer = nil
        
        EmergencySoundManager.shared.stopAlarm()
        EmergencyFlashlightManager.shared.stopStrobe()
        
        isRunning = false
        
        // Resume silent background keep-alive if in background
        if UIApplication.shared.applicationState == .background {
            BackgroundKeepAliveManager.shared.startKeepAlive()
        }
    }
}
