//
//  EmergencyFlashlightManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (Ø£ÙŠÙ† Ù‡Ù…) â€” Emergency Camera Flashlight Strobe (ÙˆÙ…ÙŠØ¶ Ø§Ù„ÙÙ„Ø§Ø´ Ù„Ù„Ø·ÙˆØ§Ø±Ø¦)
//  Matching Android EmergencyFlashlightManager.kt
//

import Foundation
import AVFoundation

class EmergencyFlashlightManager {
    static let shared = EmergencyFlashlightManager()
    
    private var strobeTimer: Timer?
    private var isTorchOn: Bool = false
    private var isStrobing: Bool = false
    
    private init() {}
    
    func startStrobe() {
        guard !isStrobing else { return }
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Flashlight torch not available on this device")
            return
        }
        
        isStrobing = true
        
        // Strobe pattern: 180ms ON, 180ms OFF (matching Android strobe)
        strobeTimer?.invalidate()
        strobeTimer = Timer.scheduledTimer(withTimeInterval: 0.18, repeats: true) { [weak self] _ in
            guard let self = self, self.isStrobing else { return }
            self.toggleTorch(device: device)
        }
    }
    
    func stopStrobe() {
        isStrobing = false
        strobeTimer?.invalidate()
        strobeTimer = nil
        
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            setTorch(device: device, on: false)
        }
    }
    
    private func toggleTorch(device: AVCaptureDevice) {
        isTorchOn.toggle()
        setTorch(device: device, on: isTorchOn)
    }
    
    private func setTorch(device: AVCaptureDevice, on: Bool) {
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
        } catch {
            // Ignore lock error on simulator
        }
    }
}