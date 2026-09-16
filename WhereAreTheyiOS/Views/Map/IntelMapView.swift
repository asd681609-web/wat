//
//  IntelMapView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Interactive Field Intel Map matching Android IntelMapScreen
//

import SwiftUI
import MapKit

struct IntelMapView: View {
    let onNoticeClick: (Int) -> Void
    
    @StateObject private var locationManager = LocationManager.shared
    @State private var notices: [Notice] = []
    @State private var selectedNotice: Notice? = nil
    @State private var isLoading: Bool = true
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 32.8872, longitude: 13.1913), // Tripoli default
        span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full Screen Map
            Map(
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: notices.filter { $0.coordinate != nil }
            ) { notice in
                MapAnnotation(coordinate: notice.coordinate!) {
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedNotice = notice
                        }
                    }) {
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(notice.isMissing ? AinTheme.red : AinTheme.emerald)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: (notice.isMissing ? AinTheme.red : AinTheme.emerald).opacity(0.4), radius: 4)
                                
                                Image(systemName: notice.isMissing ? "person.fill.questionmark" : "checkmark.seal.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Image(systemName: "triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(notice.isMissing ? AinTheme.red : AinTheme.emerald)
                                .rotationEffect(.degrees(180))
                                .offset(y: -3)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Map Floating Controls (Top Right: Center on My GPS Location)
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AinTheme.cyan)
                                .padding(12)
                                .background(AinTheme.bgSecondary)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 4)
                        }
                        
                        Button(action: loadMapNotices) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18))
                                .foregroundColor(AinTheme.textPrimary)
                                .padding(12)
                                .background(AinTheme.bgSecondary)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 4)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 50)
                }
                Spacer()
            }
            
            // Selected Notice Floating Preview Card
            if let selected = selectedNotice {
                VStack(spacing: 0) {
                    HStack(alignment: .center, spacing: 12) {
                        // Thumbnail
                        if let photoURL = selected.fullPhotoURL {
                            AsyncImage(url: photoURL) { phase in
                                if let img = phase.image {
                                    img.resizable().scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .cornerRadius(12)
                                } else {
                                    Color.gray.opacity(0.2).frame(width: 56, height: 56).cornerRadius(12)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(selected.displayName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AinTheme.textPrimary)
                            Text("\(selected.city ?? "") • #\(selected.uniqueCode)")
                                .font(.system(size: 11))
                                .foregroundColor(AinTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { onNoticeClick(selected.id) }) {
                            Text("التفاصيل")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(AinTheme.cyan)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { withAnimation { selectedNotice = nil } }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AinTheme.textMuted)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(14)
                    .background(AinTheme.bgSecondary)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90) // Above floating bar
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            loadMapNotices()
        }
    }

    private func centerOnUserLocation() {
        if let loc = locationManager.userLocation {
            withAnimation {
                region.center = loc
                region.span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            }
        } else {
            locationManager.requestLocation()
        }
    }

    private func loadMapNotices() {
        Task {
            do {
                var items = try await APIService.shared.fetchMapNotices()
                if items.isEmpty {
                    items = try await APIService.shared.fetchNotices()
                }
                await MainActor.run {
                    self.notices = items
                    self.isLoading = false
                    if let first = items.first(where: { $0.coordinate != nil }), let coord = first.coordinate {
                        withAnimation {
                            self.region.center = coord
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}