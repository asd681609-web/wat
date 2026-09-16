//
//  BackgroundKeepAliveManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — iOS Background Keep-Alive Audio Engine
//  Ensures continuous AMBER alert sync and emergency siren triggering when app is closed / phone is locked.
//

import Foundation
import AVFoundation
import UIKit

class BackgroundKeepAliveManager: ObservableObject {
    static let shared = BackgroundKeepAliveManager()
    
    private var silentPlayer: AVAudioPlayer?
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private var isRunning: Bool = false
    
    private init() {
        setupLifecycleObservers()
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        print("📱 App entered background: Activating Keep-Alive Audio Engine for AMBER sync")
        startKeepAlive()
    }
    
    @objc private func appWillEnterForeground() {
        print("📱 App entered foreground: Keep-Alive running in standby")
        endBackgroundTask()
    }
    
    func startKeepAlive() {
        guard !isRunning else { return }
        isRunning = true
        
        // 1. Begin iOS background task to extend background execution
        beginBackgroundTask()
        
        // 2. Configure audio session to run in background with mixWithOthers
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ Failed to activate background audio session: \(error)")
        }
        
        // 3. Play silent audio in infinite loop
        playSilentAudioLoop()
    }
    
    func stopKeepAlive() {
        silentPlayer?.stop()
        silentPlayer = nil
        isRunning = false
        endBackgroundTask()
    }
    
    private func playSilentAudioLoop() {
        // Try loading silent_audio.wav from bundle
        if let url = Bundle.main.url(forResource: "silent_audio", withExtension: "wav") {
            do {
                silentPlayer = try AVAudioPlayer(contentsOf: url)
                setupAndPlaySilentPlayer()
                print("✅ Background keep-alive active using silent_audio.wav")
                return
            } catch {
                print("⚠️ Error loading silent_audio.wav: \(error)")
            }
        }
        
        // Fallback: Generate 1-second silent WAV data dynamically in memory
        let silentData = generateSilentWavData()
        do {
            silentPlayer = try AVAudioPlayer(data: silentData)
            setupAndPlaySilentPlayer()
            print("✅ Background keep-alive active using generated in-memory silence")
        } catch {
            print("⚠️ Failed to create fallback silent audio player: \(error)")
        }
    }
    
    private func setupAndPlaySilentPlayer() {
        silentPlayer?.numberOfLoops = -1 // Infinite loop
        silentPlayer?.volume = 0.01     // Inaudible
        silentPlayer?.prepareToPlay()
        silentPlayer?.play()
    }
    
    private func beginBackgroundTask() {
        endBackgroundTask()
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "AinHumAmberSyncKeepAlive") { [weak self] in
            print("⚠️ Background task expiring, refreshing...")
            self?.beginBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = .invalid
        }
    }
    
    // Generates a valid 1-second 8000Hz 8-bit mono silent WAV file in pure Swift Data
    private func generateSilentWavData() -> Data {
        var data = Data()
        let sampleRate: UInt32 = 8000
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 8
        let dataSize: UInt32 = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let fileSize: UInt32 = 36 + dataSize
        
        data.append("RIFF".data(using: .ascii)!)
        var fs = fileSize
        data.append(Data(bytes: &fs, count: 4))
        data.append("WAVE".data(using: .ascii)!)
        
        data.append("fmt ".data(using: .ascii)!)
        var sub1: UInt32 = 16
        data.append(Data(bytes: &sub1, count: 4))
        var format: UInt16 = 1 // PCM
        data.append(Data(bytes: &format, count: 2))
        var ch = numChannels
        data.append(Data(bytes: &ch, count: 2))
        var sr = sampleRate
        data.append(Data(bytes: &sr, count: 4))
        var byteRate = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        data.append(Data(bytes: &byteRate, count: 4))
        var align: UInt16 = numChannels * (bitsPerSample / 8)
        data.append(Data(bytes: &align, count: 2))
        var bps = bitsPerSample
        data.append(Data(bytes: &bps, count: 2))
        
        data.append("data".data(using: .ascii)!)
        var ds = dataSize
        data.append(Data(bytes: &ds, count: 4))
        
        // 8-bit PCM silence is 128 (0x80)
        let silence = [UInt8](repeating: 128, count: Int(dataSize))
        data.append(contentsOf: silence)
        
        return data
    }
}
