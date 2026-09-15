//
//  NoticeCardView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct NoticeCardView: View {
    let notice: Notice
    
    var body: some View {
        HStack(spacing: 14) {
            // Photo Container
            ZStack(alignment: .topLeading) {
                if let photoURL = notice.fullPhotoURL {
                    AsyncImage(url: photoURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 90, height: 105)
                                .background(Color(red: 0.1, green: 0.15, blue: 0.25))
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 105)
                                .clipped()
                        case .failure:
                            fallbackPhoto
                        @unknown default:
                            fallbackPhoto
                        }
                    }
                } else {
                    fallbackPhoto
                }
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            // Notice Details
            VStack(alignment: .trailing, spacing: 6) {
                HStack {
                    StatusBadge(type: notice.type ?? "missing")
                    
                    Spacer()
                    
                    if let code = notice.uniqueCode {
                        Text("#\(code)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.gray)
                    }
                }
                
                Text(notice.fullName ?? "اسم غير معروف")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .environment(\.layoutDirection, .rightToLeft)
                
                HStack(spacing: 12) {
                    if let age = notice.ageEstimate, !age.isEmpty {
                        Label("\(age) سنة", systemImage: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    if let city = notice.city, !city.isEmpty {
                        Label(city, systemImage: "mappin.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.23, green: 0.51, blue: 0.96))
                    }
                }
                .environment(\.layoutDirection, .rightToLeft)
                
                if let lastSeen = notice.lastSeenPlace ?? notice.district, !lastSeen.isEmpty {
                    Text("آخر مشاهدة: \(lastSeen)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineLimit(1)
                        .environment(\.layoutDirection, .rightToLeft)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(12)
        .background(
            Color(red: 0.06, green: 0.09, blue: 0.16)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    notice.isMissing ? Color.red.opacity(0.2) : Color.green.opacity(0.2),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var fallbackPhoto: some View {
        ZStack {
            Color(red: 0.09, green: 0.13, blue: 0.22)
            Image(systemName: "person.crop.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(Color.gray.opacity(0.5))
        }
        .frame(width: 90, height: 105)
    }
}
