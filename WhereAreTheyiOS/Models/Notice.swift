//
//  Notice.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Complete Data Models matching Android
//

import Foundation
import CoreLocation

// MARK: - Generic API Response
struct ApiResponse<T: Codable>: Codable {
    let status: String
    let message: String?
    let data: T?
}

// MARK: - Notice Model
struct Notice: Codable, Identifiable, Hashable {
    let id: Int
    let uniqueCode: String
    let type: String // "missing", "found", "deceased", "unidentified"
    let fullName: String?
    let gender: String?
    let ageEstimate: Int?
    let city: String?
    let district: String?
    let description: String?
    let contactPhone: String?
    let physicalDescription: String?
    let incidentDate: String?
    let photoUrl: String?
    let lat: Double?
    let lng: Double?
    let status: String? // "active", "resolved", "deceased", "investigating"
    let priorityLevel: String?
    let createdAt: String?
    let daysSince: Int?
    let distanceKm: Double?
    
    // Medical & Special Needs
    let specialNeeds: String?
    let urgentMedicationRequired: Int?
    let medicationName: String?
    let bloodType: String?
    let specialInstructions: String?
    
    // Personal Physical Characteristics
    let nickname: String?
    let nationalId: String?
    let passportNo: String?
    let nationality: String?
    let missingPhone: String?
    let heightCm: String?
    let weightKg: String?
    let eyeColor: String?
    let hairColor: String?
    let skinColor: String?
    let bodyBuild: String?
    let facialHair: String?
    let languageDialect: String?
    let clothesDescription: String?
    let personalBelongings: String?
    let vehicleDetails: String?
    let isPrivatePhoto: Int?
    let autoPrivacyBlurred: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case uniqueCode = "unique_code"
        case type
        case fullName = "full_name"
        case gender
        case ageEstimate = "age_estimate"
        case city
        case district
        case description
        case contactPhone = "contact_phone"
        case physicalDescription = "physical_description"
        case incidentDate = "incident_date"
        case photoUrl = "photo_url"
        case lat, lng, status
        case priorityLevel = "priority_level"
        case createdAt = "created_at"
        case daysSince = "days_since"
        case distanceKm = "distance_km"
        case specialNeeds = "special_needs"
        case urgentMedicationRequired = "urgent_medication_required"
        case medicationName = "medication_name"
        case bloodType = "blood_type"
        case specialInstructions = "special_instructions"
        case nickname
        case nationalId = "national_id"
        case passportNo = "passport_no"
        case nationality
        case missingPhone = "missing_phone"
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case eyeColor = "eye_color"
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case bodyBuild = "body_build"
        case facialHair = "facial_hair"
        case languageDialect = "language_dialect"
        case clothesDescription = "clothes_description"
        case personalBelongings = "personal_belongings"
        case vehicleDetails = "vehicle_details"
        case isPrivatePhoto = "is_private_photo"
        case autoPrivacyBlurred = "auto_privacy_blurred"
    }

    // Helper computed properties
    var isMissing: Bool { type == "missing" }
    var isFound: Bool { type == "found" }
    var isResolved: Bool { status == "resolved" }
    var isDeceased: Bool { status == "deceased" }
    
    var displayName: String {
        if isResolved || autoPrivacyBlurred == 1 {
            return "بلاغ مغلق: #\(uniqueCode)"
        }
        return fullName?.isEmpty == false ? fullName! : (isMissing ? "شخص مجهول الهوية" : "معثور عليه")
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = lat, let lng = lng, lat != 0, lng != 0 else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    var fullPhotoURL: URL? {
        guard let photo = photoUrl, !photo.isEmpty else { return nil }
        if photo.starts(with: "http") { return URL(string: photo) }
        return URL(string: "https://wat.org.ly/" + photo)
    }
}

// MARK: - Notices Pagination List
struct NoticesData: Codable {
    let total: Int?
    let page: Int?
    let limit: Int?
    let pages: Int?
    let items: [Notice]
}

// MARK: - Notice Detail Data
struct NoticeDetailData: Codable {
    let notice: Notice
    let tips: [Tip]?
    let adminUpdates: [AdminUpdateItem]?
    let sightings: [SightingItem]?

    enum CodingKeys: String, CodingKey {
        case notice
        case tips
        case adminUpdates = "admin_updates"
        case sightings
    }
}

struct Tip: Codable, Identifiable {
    let id: Int
    let content: String?
    let locationDescription: String?
    let contactPhone: String?
    let lat: Double?
    let lng: Double?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, content
        case locationDescription = "location_description"
        case contactPhone = "contact_phone"
        case lat, lng
        case createdAt = "created_at"
    }
}

struct AdminUpdateItem: Codable, Identifiable {
    let id: Int
    let noticeId: Int?
    let updateType: String?
    let title: String
    let content: String
    let adminName: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case noticeId = "notice_id"
        case updateType = "update_type"
        case title, content
        case adminName = "admin_name"
        case createdAt = "created_at"
    }
}

struct SightingItem: Codable, Identifiable {
    let id: Int
    let noticeId: Int?
    let eventType: String?
    let title: String
    let description: String?
    let latitude: Double
    let longitude: Double
    let eventTime: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case noticeId = "notice_id"
        case eventType = "event_type"
        case title, description, latitude, longitude
        case eventTime = "event_time"
        case createdAt = "created_at"
    }
}

// MARK: - AMBER Alert
struct AmberAlertData: Codable {
    let count: Int?
    let alerts: [AmberAlert]
}

struct AmberAlert: Codable, Identifiable {
    let id: Int
    let message: String
    let coverageCity: String
    let uniqueCode: String
    let fullName: String?
    let photoUrl: String?
    let issuedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, message
        case coverageCity = "coverage_city"
        case uniqueCode = "unique_code"
        case fullName = "full_name"
        case photoUrl = "photo_url"
        case issuedAt = "issued_at"
    }
}

// MARK: - Platform Stats
struct PlatformStats: Codable {
    let totalMissing: Int
    let totalFound: Int
    let totalResolved: Int
    let totalVolunteers: Int
    let resolutionRate: Double
    let avgDaysToResolve: Double
    let byCity: [CityCount]?

    enum CodingKeys: String, CodingKey {
        case totalMissing = "total_missing"
        case totalFound = "total_found"
        case totalResolved = "total_resolved"
        case totalVolunteers = "total_volunteers_approved"
        case resolutionRate = "resolution_rate"
        case avgDaysToResolve = "avg_days_to_resolve"
        case byCity = "by_city"
    }

    static let placeholder = PlatformStats(
        totalMissing: 48,
        totalFound: 183,
        totalResolved: 172,
        totalVolunteers: 620,
        resolutionRate: 88.5,
        avgDaysToResolve: 3.2,
        byCity: [
            CityCount(city: "طرابلس", count: 85),
            CityCount(city: "بنغازي", count: 42),
            CityCount(city: "مصراتة", count: 28),
            CityCount(city: "سبها", count: 19)
        ]
    )
}

struct CityCount: Codable, Identifiable {
    var id: String { city ?? UUID().uuidString }
    let city: String?
    let count: Int
}

// MARK: - Family Portal
struct FamilyPortalData: Codable {
    let notice: Notice?
    let updates: [Tip]?
}
typealias FamilyPortalResponse = FamilyPortalData

// MARK: - Ops Chat Message
struct OpsChatMessage: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let senderType: String // "user" or "ops" or "system"
    let senderName: String?
    let message: String?
    let attachmentUrl: String?
    let attachmentType: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case senderType = "sender_type"
        case senderName = "sender_name"
        case message
        case attachmentUrl = "attachment_url"
        case attachmentType = "attachment_type"
        case createdAt = "created_at"
    }

    var isFromOps: Bool { senderType != "user" }
}

// MARK: - Partner Entity
struct PartnerEntity: Codable, Identifiable {
    let id: Int
    let name: String
    let logoUrl: String?
    let linkUrl: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoUrl = "logo_url"
        case linkUrl = "link_url"
        case category
    }

    static let defaultPartners: [PartnerEntity] = [
        PartnerEntity(id: 1, name: "الهلال الأحمر الليبي", logoUrl: nil, linkUrl: nil, category: "طوارئ وإغاثة"),
        PartnerEntity(id: 2, name: "جهاز المباحث الجنائية", logoUrl: nil, linkUrl: nil, category: "أمني"),
        PartnerEntity(id: 3, name: "غرفة عمليات الطوارئ 1515", logoUrl: nil, linkUrl: nil, category: "خط ساخن"),
        PartnerEntity(id: 4, name: "وزارة الصحة الليبية", logoUrl: nil, linkUrl: nil, category: "مستشفيات"),
        PartnerEntity(id: 5, name: "مركز الطب والطوارئ والدعم", logoUrl: nil, linkUrl: nil, category: "إسعاف")
    ]
}

// MARK: - Volunteer
struct VolunteerItem: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let fullName: String?
    let city: String?
    let skills: String?
    let availabilityStatus: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case fullName = "full_name"
        case city, skills
        case availabilityStatus = "availability_status"
    }
}

// MARK: - Auth Response
struct LoginResponse: Codable {
    let token: String
    let userId: Int
    let name: String
    let email: String?
    let phone: String?
    let role: String
    let entityType: String?

    enum CodingKeys: String, CodingKey {
        case token
        case userId = "user_id"
        case name, email, phone, role
        case entityType = "entity_type"
    }
}
