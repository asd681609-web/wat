//
//  IntelMapView.swift
//  WhereAreTheyiOS
//
//  خريطة البلاغات الميدانية الحية وإظهار موقع المستخدم والمسافة الحقيقية بالـ كم
//

import SwiftUI
import MapKit
import CoreLocation

struct MapAnnotationItem: Identifiable {
    let id: Int
    let notice: Notice
    let coordinate: CLLocationCoordinate2D
}

struct IntelMapView: View {
    @StateObject private var viewModel = NoticesViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 27.0, longitude: 17.0), // Center of Libya
        span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0)
    )
    
    @State private var selectedNotice: Notice? = nil
    
    var annotations: [MapAnnotationItem] {
        return viewModel.notices.compactMap { item in
            guard let lat = item.lat, let lng = item.lng, lat != 0.0, lng != 0.0 else { return nil }
            return MapAnnotationItem(id: item.id, notice: item, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        }
    }
    
    // Calculate distance in kilometers
    func distanceInKM(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let userLoc = locationManager.location else { return nil }
        let userCLLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        let targetCLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userCLLocation.distance(from: targetCLLocation) / 1000.0
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Interactive Map showing User Location & Missing Person Pins
                Map(
                    coordinateRegion: $region,
                    showsUserLocation: true,
                    userTrackingMode: .constant(.follow),
                    annotationItems: annotations
                ) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        Button(action: {
                            selectedNotice = item.notice
                        }) {
                            VStack(spacing: 2) {
                                ZStack {
                                    Circle()
                                        .fill(item.notice.isMissing ? Color.red : Color.green)
                                        .frame(width: 34, height: 34)
                                        .shadow(color: item.notice.isMissing ? .red.opacity(0.5) : .green.opacity(0.5), radius: 6)
                                    Image(systemName: item.notice.isMissing ? "person.fill.questionmark" : "checkmark.seal.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Show Distance Badge under pin if user location is available
                                if let dist = distanceInKM(to: item.coordinate) {
                                    Text(String(format: "%.1f كم", dist))
                                        .font(.system(size: 10, weight: .bold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.85))
                                        .foregroundColor(.yellow)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // Overlay Header with Location Permission Action
                VStack {
                    HStack {
                        Button(action: {
                            locationManager.requestLocationPermission()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: locationManager.location != nil ? "location.fill" : "location.slash")
                                    .foregroundColor(locationManager.location != nil ? .green : .orange)
                                Text(locationManager.location != nil ? "موقعك نشط" : "تفعيل الموقع")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.04, green: 0.06, blue: 0.12).opacity(0.9))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("🗺️ خريطة البلاغات الحية")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.04, green: 0.06, blue: 0.12).opacity(0.9))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    Spacer()
                }
                
                // Selected Notice Bottom Preview Sheet with Distance Indicator
                if let notice = selectedNotice {
                    VStack(spacing: 8) {
                        HStack {
                            if let lat = notice.lat, let lng = notice.lng,
                               let dist = distanceInKM(to: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.north.line.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "يبعد عن موقعك الحالي: %.1f كم", dist))
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.yellow)
                                }
                            } else {
                                Text("📍 تتبع الإحداثيات الحية")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: { selectedNotice = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        NavigationLink(destination: NoticeDetailView(notice: notice)) {
                            NoticeCardView(notice: notice)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(14)
                    .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.5), radius: 12)
                    .padding(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            locationManager.requestLocationPermission()
            await viewModel.loadNotices()
        }
    }
}
