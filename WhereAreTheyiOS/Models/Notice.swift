//
//  Notice.swift
//  WhereAreTheyiOS
//
//  Created for AinHum (أين هم) Platform.
//

import Foundation

// MARK: - Notice Item Model
struct Notice: Identifiable, Codable {
    let id: Int
    let uniqueCode: String?
    let type: String? // "missing" or "found"
    let fullName: String?
    let ageEstimate: String?
    let gender: String?
    let photoUrl: String?
    let city: String?
    let district: String?
    let lastSeenDate: String?
    let lastSeenPlace: String?
    let lat: Double?
    let lng: Double?
    let status: String? // "active", "resolved", "closed"
    let priorityLevel: String? // "urgent", "high", "normal"
    let chronicDiseases: String?
    let personalBelongings: String?
    let vehicleDetails: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case uniqueCode = "unique_code"
        case type
        case fullName = "full_name"
        case ageEstimate = "age_estimate"
        case gender
        case photoUrl = "photo_url"
        case city
        case district
        case lastSeenDate = "last_seen_date"
        case lastSeenPlace = "last_seen_place"
        case lat
        case lng
        case status
        case priorityLevel = "priority_level"
        case chronicDiseases = "chronic_diseases"
        case personalBelongings = "personal_belongings"
        case vehicleDetails = "vehicle_details"
        case createdAt = "created_at"
    }
    
    var isMissing: Bool {
        return (type ?? "missing") == "missing"
    }
    
    var fullPhotoURL: URL? {
        guard let photo = photoUrl, !photo.isEmpty else { return nil }
        if photo.hasPrefix("http") {
            return URL(string: photo)
        }
        return URL(string: "https://wat.org.ly/" + photo.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
}

// MARK: - AMBER Alert Model
struct AmberAlert: Identifiable, Codable {
    let id: Int
    let noticeId: Int?
    let message: String?
    let coverageCity: String?
    let radiusKm: Int?
    let targetAudience: String?
    let status: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case noticeId = "notice_id"
        case message
        case coverageCity = "coverage_city"
        case radiusKm = "radius_km"
        case targetAudience = "target_audience"
        case status
        case createdAt = "created_at"
    }
}

// MARK: - Field Tip Model
struct FieldTip: Identifiable, Codable {
    let id: Int
    let noticeId: Int?
    let content: String?
    let locationDescription: String?
    let contactPhone: String?
    let reporterName: String?
    let photoUrl: String?
    let status: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case noticeId = "notice_id"
        case content
        case locationDescription = "location_description"
        case contactPhone = "contact_phone"
        case reporterName = "reporter_name"
        case photoUrl = "photo_url"
        case status
        case createdAt = "created_at"
    }
}

// MARK: - Platform Stats Data Model
struct PlatformStats: Codable {
    let totalMissing: Int
    let totalFound: Int
    let totalResolved: Int
    let totalVolunteers: Int
    let resolutionRate: Double
    let avgDaysToResolve: Double
    let byCity: [CityCount]
    
    enum CodingKeys: String, CodingKey {
        case totalMissing = "total_missing"
        case totalFound = "total_found"
        case totalResolved = "total_resolved"
        case totalVolunteers = "total_volunteers_approved"
        case resolutionRate = "resolution_rate"
        case avgDaysToResolve = "avg_days_to_resolve"
        case byCity = "by_city"
    }
    
    static var placeholder: PlatformStats {
        return PlatformStats(totalMissing: 0, totalFound: 0, totalResolved: 0, totalVolunteers: 0, resolutionRate: 0.0, avgDaysToResolve: 0.0, byCity: [])
    }
}

struct CityCount: Identifiable, Codable {
    var id: String { city ?? UUID().uuidString }
    let city: String?
    let count: Int
}

// MARK: - Family Portal Data Model
struct FamilyPortalResponse: Codable {
    let notice: Notice?
    let updates: [FamilyUpdate]
}

struct FamilyUpdate: Identifiable, Codable {
    var id: String { createdAt ?? UUID().uuidString }
    let createdAt: String?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case content
    }
}

// MARK: - Volunteer Model
struct VolunteerItem: Identifiable, Codable {
    let id: Int
    let fullName: String?
    let city: String?
    let skills: String?
    let availabilityStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case city
        case skills
        case availabilityStatus = "availability_status"
    }
}

// MARK: - Generic API Response Wrapper
struct ApiResponse<T: Codable>: Codable {
    let status: String?
    let message: String?
    let data: T?
}
