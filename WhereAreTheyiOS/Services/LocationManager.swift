//
//  LocationManager.swift
//  WhereAreTheyiOS
//
//  إدارة إذن وتحديث إحداثيات موقع الهاتف (GPS) المباشرة لغرفة العمليات
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLiveTrackingActive: Bool = false
    
    private var pingTimer: Timer? = nil
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = kCLDistanceFilterNone
        authorizationStatus = manager.authorizationStatus
    }
    
    // Request Location Permission from User
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    // Start Live GPS Tracking for Volunteers / Field Units
    func startLiveFieldTracking(userId: Int?, name: String, phone: String, city: String) {
        requestLocationPermission()
        manager.startUpdatingLocation()
        isLiveTrackingActive = true
        
        // Timer to ping server every 20 seconds
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] _ in
            guard let self = self, let loc = self.location else { return }
            Task {
                try? await APIService.shared.updateVolunteerLocation(
                    userId: userId,
                    name: name,
                    phone: phone,
                    city: city,
                    lat: loc.latitude,
                    lng: loc.longitude,
                    isOnline: true
                )
            }
        }
    }
    
    // Stop Live Tracking
    func stopLiveFieldTracking() {
        manager.stopUpdatingLocation()
        pingTimer?.invalidate()
        pingTimer = nil
        isLiveTrackingActive = false
    }
    
    // CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        DispatchQueue.main.async {
            self.location = latest.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
}
