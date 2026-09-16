//
//  EmergencySoundManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Emergency Siren Audio & Vibration Manager
//  Matching Android EmergencySoundManager.kt with amber_alert_siren.wav
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

class EmergencySoundManager {
    static let shared = EmergencySoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var vibrationTimer: Timer?
    
    private init() {}
    
    func playEmergencyAlarm() {
        stopAlarm()
        
        // 1. Force audio through speaker at full volume even if mute switch is on
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Failed to configure emergency audio session: \(error)")
        }
        
        // 2. Play amber_alert_siren.wav
        if let url = Bundle.main.url(forResource: "amber_alert_siren", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop continuously
                audioPlayer?.volume = 1.0
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                print("🚨 Playing amber_alert_siren.wav emergency siren")
            } catch {
                print("Failed to play amber_alert_siren.wav: \(error)")
                playFallbackSystemSound()
            }
        } else {
            print("amber_alert_siren.wav not found in main bundle, using system sound")
            playFallbackSystemSound()
        }
        
        // 3. Start strong vibration pulse
        startStrongVibration()
    }
    
    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
        stopVibration()
    }
    
    private func playFallbackSystemSound() {
        AudioServicesPlaySystemSound(1005)
    }
    
    private func startStrongVibration() {
        vibrationTimer?.invalidate()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.error)
        
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            feedback.notificationOccurred(.error)
        }
    }
    
    private func stopVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
}
