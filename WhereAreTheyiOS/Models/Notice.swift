//
//  Notice.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Complete Data Models matching Android & PHP Backend
//

import Foundation
import CoreLocation

// MARK: - KeyedDecodingContainer Flexible Helpers
extension KeyedDecodingContainer {
    func decodeFlexibleDouble(forKey key: Key) -> Double? {
        if let val = try? decodeIfPresent(Double.self, forKey: key) { return val }
        if let str = try? decodeIfPresent(String.self, forKey: key),
           let val = Double(str.trimmingCharacters(in: .whitespacesAndNewlines)) { return val }
        if let intVal = try? decodeIfPresent(Int.self, forKey: key) { return Double(intVal) }
        return nil
    }

    func decodeFlexibleInt(forKey key: Key) -> Int? {
        if let val = try? decodeIfPresent(Int.self, forKey: key) { return val }
        if let str = try? decodeIfPresent(String.self, forKey: key) {
            let clean = str.trimmingCharacters(in: .whitespacesAndNewlines)
            if let val = Int(clean) { return val }
            if let dbl = Double(clean) { return Int(dbl) }
        }
        if let dblVal = try? decodeIfPresent(Double.self, forKey: key) { return Int(dblVal) }
        return nil
    }

    func decodeFlexibleString(forKey key: Key) -> String? {
        if let str = try? decodeIfPresent(String.self, forKey: key) { return str }
        if let intVal = try? decodeIfPresent(Int.self, forKey: key) { return String(intVal) }
        if let dblVal = try? decodeIfPresent(Double.self, forKey: key) { return String(dblVal) }
        return nil
    }
}

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

    init(
        id: Int,
        uniqueCode: String,
        type: String = "missing",
        fullName: String? = nil,
        gender: String? = nil,
        ageEstimate: Int? = nil,
        city: String? = nil,
        district: String? = nil,
        description: String? = nil,
        contactPhone: String? = nil,
        physicalDescription: String? = nil,
        incidentDate: String? = nil,
        photoUrl: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        status: String? = "active",
        priorityLevel: String? = "normal",
        createdAt: String? = nil,
        daysSince: Int? = nil,
        distanceKm: Double? = nil,
        specialNeeds: String? = nil,
        urgentMedicationRequired: Int? = nil,
        medicationName: String? = nil,
        bloodType: String? = nil,
        specialInstructions: String? = nil,
        nickname: String? = nil,
        nationalId: String? = nil,
        passportNo: String? = nil,
        nationality: String? = nil,
        missingPhone: String? = nil,
        heightCm: String? = nil,
        weightKg: String? = nil,
        eyeColor: String? = nil,
        hairColor: String? = nil,
        skinColor: String? = nil,
        bodyBuild: String? = nil,
        facialHair: String? = nil,
        languageDialect: String? = nil,
        clothesDescription: String? = nil,
        personalBelongings: String? = nil,
        vehicleDetails: String? = nil,
        isPrivatePhoto: Int? = nil,
        autoPrivacyBlurred: Int? = nil
    ) {
        self.id = id
        self.uniqueCode = uniqueCode
        self.type = type
        self.fullName = fullName
        self.gender = gender
        self.ageEstimate = ageEstimate
        self.city = city
        self.district = district
        self.description = description
        self.contactPhone = contactPhone
        self.physicalDescription = physicalDescription
        self.incidentDate = incidentDate
        self.photoUrl = photoUrl
        self.lat = lat
        self.lng = lng
        self.status = status
        self.priorityLevel = priorityLevel
        self.createdAt = createdAt
        self.daysSince = daysSince
        self.distanceKm = distanceKm
        self.specialNeeds = specialNeeds
        self.urgentMedicationRequired = urgentMedicationRequired
        self.medicationName = medicationName
        self.bloodType = bloodType
        self.specialInstructions = specialInstructions
        self.nickname = nickname
        self.nationalId = nationalId
        self.passportNo = passportNo
        self.nationality = nationality
        self.missingPhone = missingPhone
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.eyeColor = eyeColor
        self.hairColor = hairColor
        self.skinColor = skinColor
        self.bodyBuild = bodyBuild
        self.facialHair = facialHair
        self.languageDialect = languageDialect
        self.clothesDescription = clothesDescription
        self.personalBelongings = personalBelongings
        self.vehicleDetails = vehicleDetails
        self.isPrivatePhoto = isPrivatePhoto
        self.autoPrivacyBlurred = autoPrivacyBlurred
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.uniqueCode = (try? container.decodeIfPresent(String.self, forKey: .uniqueCode)) ?? "AIN-MIS"
        self.type = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? "missing"
        self.fullName = try? container.decodeIfPresent(String.self, forKey: .fullName)
        self.gender = try? container.decodeIfPresent(String.self, forKey: .gender)
        self.ageEstimate = container.decodeFlexibleInt(forKey: .ageEstimate)
        self.city = try? container.decodeIfPresent(String.self, forKey: .city)
        self.district = try? container.decodeIfPresent(String.self, forKey: .district)
        self.description = try? container.decodeIfPresent(String.self, forKey: .description)
        self.contactPhone = container.decodeFlexibleString(forKey: .contactPhone)
        self.physicalDescription = try? container.decodeIfPresent(String.self, forKey: .physicalDescription)
        self.incidentDate = try? container.decodeIfPresent(String.self, forKey: .incidentDate)
        self.photoUrl = try? container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.lat = container.decodeFlexibleDouble(forKey: .lat)
        self.lng = container.decodeFlexibleDouble(forKey: .lng)
        self.status = try? container.decodeIfPresent(String.self, forKey: .status)
        self.priorityLevel = try? container.decodeIfPresent(String.self, forKey: .priorityLevel)
        self.createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
        self.daysSince = container.decodeFlexibleInt(forKey: .daysSince)
        self.distanceKm = container.decodeFlexibleDouble(forKey: .distanceKm)
        
        self.specialNeeds = try? container.decodeIfPresent(String.self, forKey: .specialNeeds)
        self.urgentMedicationRequired = container.decodeFlexibleInt(forKey: .urgentMedicationRequired)
        self.medicationName = try? container.decodeIfPresent(String.self, forKey: .medicationName)
        self.bloodType = try? container.decodeIfPresent(String.self, forKey: .bloodType)
        self.specialInstructions = try? container.decodeIfPresent(String.self, forKey: .specialInstructions)
        
        self.nickname = try? container.decodeIfPresent(String.self, forKey: .nickname)
        self.nationalId = container.decodeFlexibleString(forKey: .nationalId)
        self.passportNo = container.decodeFlexibleString(forKey: .passportNo)
        self.nationality = try? container.decodeIfPresent(String.self, forKey: .nationality)
        self.missingPhone = container.decodeFlexibleString(forKey: .missingPhone)
        self.heightCm = container.decodeFlexibleString(forKey: .heightCm)
        self.weightKg = container.decodeFlexibleString(forKey: .weightKg)
        self.eyeColor = try? container.decodeIfPresent(String.self, forKey: .eyeColor)
        self.hairColor = try? container.decodeIfPresent(String.self, forKey: .hairColor)
        self.skinColor = try? container.decodeIfPresent(String.self, forKey: .skinColor)
        self.bodyBuild = try? container.decodeIfPresent(String.self, forKey: .bodyBuild)
        self.facialHair = try? container.decodeIfPresent(String.self, forKey: .facialHair)
        self.languageDialect = try? container.decodeIfPresent(String.self, forKey: .languageDialect)
        self.clothesDescription = try? container.decodeIfPresent(String.self, forKey: .clothesDescription)
        self.personalBelongings = try? container.decodeIfPresent(String.self, forKey: .personalBelongings)
        self.vehicleDetails = try? container.decodeIfPresent(String.self, forKey: .vehicleDetails)
        self.isPrivatePhoto = container.decodeFlexibleInt(forKey: .isPrivatePhoto)
        self.autoPrivacyBlurred = container.decodeFlexibleInt(forKey: .autoPrivacyBlurred)
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
        if let name = fullName, !name.trimmingCharacters(in: .whitespaces).isEmpty {
            return name
        }
        return isMissing ? "شخص مجهول الهوية" : "معثور عليه"
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

    enum CodingKeys: String, CodingKey {
        case total, page, limit, pages, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.total = container.decodeFlexibleInt(forKey: .total)
        self.page = container.decodeFlexibleInt(forKey: .page)
        self.limit = container.decodeFlexibleInt(forKey: .limit)
        self.pages = container.decodeFlexibleInt(forKey: .pages)
        self.items = (try? container.decode([Notice].self, forKey: .items)) ?? []
    }
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

    init(
        id: Int,
        content: String? = nil,
        locationDescription: String? = nil,
        contactPhone: String? = nil,
        lat: Double? = nil,
        lng: Double? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.content = content
        self.locationDescription = locationDescription
        self.contactPhone = contactPhone
        self.lat = lat
        self.lng = lng
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.content = try? container.decodeIfPresent(String.self, forKey: .content)
        self.locationDescription = try? container.decodeIfPresent(String.self, forKey: .locationDescription)
        self.contactPhone = container.decodeFlexibleString(forKey: .contactPhone)
        self.lat = container.decodeFlexibleDouble(forKey: .lat)
        self.lng = container.decodeFlexibleDouble(forKey: .lng)
        self.createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
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

    init(
        id: Int,
        noticeId: Int? = nil,
        updateType: String? = nil,
        title: String = "تحديث إداري",
        content: String = "",
        adminName: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.noticeId = noticeId
        self.updateType = updateType
        self.title = title
        self.content = content
        self.adminName = adminName
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.noticeId = container.decodeFlexibleInt(forKey: .noticeId)
        self.updateType = try? container.decodeIfPresent(String.self, forKey: .updateType)
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? "تحديث إداري"
        self.content = (try? container.decodeIfPresent(String.self, forKey: .content)) ?? ""
        self.adminName = try? container.decodeIfPresent(String.self, forKey: .adminName)
        self.createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
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

    init(
        id: Int,
        noticeId: Int? = nil,
        eventType: String? = nil,
        title: String = "مشاهدة ميدانية",
        description: String? = nil,
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        eventTime: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.noticeId = noticeId
        self.eventType = eventType
        self.title = title
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.eventTime = eventTime
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.noticeId = container.decodeFlexibleInt(forKey: .noticeId)
        self.eventType = try? container.decodeIfPresent(String.self, forKey: .eventType)
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? "مشاهدة ميدانية"
        self.description = try? container.decodeIfPresent(String.self, forKey: .description)
        self.latitude = container.decodeFlexibleDouble(forKey: .latitude) ?? 0.0
        self.longitude = container.decodeFlexibleDouble(forKey: .longitude) ?? 0.0
        self.eventTime = try? container.decodeIfPresent(String.self, forKey: .eventTime)
        self.createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
    }
}

// MARK: - AMBER Alert
struct AmberAlertData: Codable {
    let count: Int?
    let alerts: [AmberAlert]

    enum CodingKeys: String, CodingKey {
        case count, alerts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = container.decodeFlexibleInt(forKey: .count)
        self.alerts = (try? container.decode([AmberAlert].self, forKey: .alerts)) ?? []
    }
}

struct AmberAlert: Codable, Identifiable, Hashable {
    let id: Int
    let noticeId: Int?
    let message: String
    let coverageCity: String
    let radiusKm: Int?
    let uniqueCode: String
    let fullName: String?
    let gender: String?
    let ageEstimate: String?
    let noticeCity: String?
    let photoUrl: String?
    let issuedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case noticeId = "notice_id"
        case message
        case coverageCity = "coverage_city"
        case radiusKm = "radius_km"
        case uniqueCode = "unique_code"
        case fullName = "full_name"
        case gender
        case ageEstimate = "age_estimate"
        case noticeCity = "notice_city"
        case photoUrl = "photo_url"
        case issuedAt = "issued_at"
    }

    init(
        id: Int,
        noticeId: Int? = nil,
        message: String,
        coverageCity: String,
        radiusKm: Int? = 15,
        uniqueCode: String,
        fullName: String? = nil,
        gender: String? = nil,
        ageEstimate: String? = nil,
        noticeCity: String? = nil,
        photoUrl: String? = nil,
        issuedAt: String? = nil
    ) {
        self.id = id
        self.noticeId = noticeId
        self.message = message
        self.coverageCity = coverageCity
        self.radiusKm = radiusKm
        self.uniqueCode = uniqueCode
        self.fullName = fullName
        self.gender = gender
        self.ageEstimate = ageEstimate
        self.noticeCity = noticeCity
        self.photoUrl = photoUrl
        self.issuedAt = issuedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.noticeId = container.decodeFlexibleInt(forKey: .noticeId)
        self.message = (try? container.decodeIfPresent(String.self, forKey: .message)) ?? "تنبيه طوارئ عاجل"
        self.coverageCity = (try? container.decodeIfPresent(String.self, forKey: .coverageCity)) ?? "ليبيا"
        self.radiusKm = container.decodeFlexibleInt(forKey: .radiusKm)
        self.uniqueCode = (try? container.decodeIfPresent(String.self, forKey: .uniqueCode)) ?? "AIN-ALERT"
        self.fullName = try? container.decodeIfPresent(String.self, forKey: .fullName)
        self.gender = try? container.decodeIfPresent(String.self, forKey: .gender)
        self.ageEstimate = container.decodeFlexibleString(forKey: .ageEstimate)
        self.noticeCity = try? container.decodeIfPresent(String.self, forKey: .noticeCity)
        
        let pUrl = try? container.decodeIfPresent(String.self, forKey: .photoUrl)
        
        var fallbackPhoto: String? = nil
        if let rawContainer = try? decoder.container(keyedBy: RawFallbackKeys.self) {
            fallbackPhoto = try? rawContainer.decodeIfPresent(String.self, forKey: .photo)
        }
        self.photoUrl = pUrl ?? fallbackPhoto
        self.issuedAt = try? container.decodeIfPresent(String.self, forKey: .issuedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(noticeId, forKey: .noticeId)
        try container.encode(message, forKey: .message)
        try container.encode(coverageCity, forKey: .coverageCity)
        try container.encodeIfPresent(radiusKm, forKey: .radiusKm)
        try container.encode(uniqueCode, forKey: .uniqueCode)
        try container.encodeIfPresent(fullName, forKey: .fullName)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(ageEstimate, forKey: .ageEstimate)
        try container.encodeIfPresent(noticeCity, forKey: .noticeCity)
        try container.encodeIfPresent(photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(issuedAt, forKey: .issuedAt)
    }

    private enum RawFallbackKeys: String, CodingKey {
        case photo
    }
}

// MARK: - Platform Stats
struct PlatformStats: Codable {
    let totalMissing: Int
    let totalFound: Int
    let totalResolved: Int
    let totalVolunteers: Int
    let totalVisitors: Int?
    let currentlyActive: Int?
    let amberRecipients: Int?
    let resolutionRate: Double
    let avgDaysToResolve: Double
    let byCity: [CityCount]?

    enum CodingKeys: String, CodingKey {
        case totalMissing = "total_missing"
        case totalFound = "total_found"
        case totalResolved = "total_resolved"
        case totalVolunteers = "total_volunteers"
        case totalVisitors = "total_visitors"
        case currentlyActive = "currently_active"
        case amberRecipients = "amber_recipients"
        case resolutionRate = "resolution_rate"
        case avgDaysToResolve = "avg_days_to_resolve"
        case byCity = "by_city"
    }

    init(
        totalMissing: Int,
        totalFound: Int,
        totalResolved: Int,
        totalVolunteers: Int,
        totalVisitors: Int? = 0,
        currentlyActive: Int? = 0,
        amberRecipients: Int? = 0,
        resolutionRate: Double,
        avgDaysToResolve: Double,
        byCity: [CityCount]? = nil
    ) {
        self.totalMissing = totalMissing
        self.totalFound = totalFound
        self.totalResolved = totalResolved
        self.totalVolunteers = totalVolunteers
        self.totalVisitors = totalVisitors
        self.currentlyActive = currentlyActive
        self.amberRecipients = amberRecipients
        self.resolutionRate = resolutionRate
        self.avgDaysToResolve = avgDaysToResolve
        self.byCity = byCity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.totalMissing = container.decodeFlexibleInt(forKey: .totalMissing) ?? 0
        self.totalFound = container.decodeFlexibleInt(forKey: .totalFound) ?? 0
        self.totalResolved = container.decodeFlexibleInt(forKey: .totalResolved) ?? 0
        
        var approvedVolunteers: Int? = nil
        if let rawContainer = try? decoder.container(keyedBy: RawStatsKeys.self) {
            approvedVolunteers = rawContainer.decodeFlexibleInt(forKey: .totalVolunteersApproved)
        }
        let standard = container.decodeFlexibleInt(forKey: .totalVolunteers)
        self.totalVolunteers = approvedVolunteers ?? standard ?? 0
        
        self.totalVisitors = container.decodeFlexibleInt(forKey: .totalVisitors)
        self.currentlyActive = container.decodeFlexibleInt(forKey: .currentlyActive)
        self.amberRecipients = container.decodeFlexibleInt(forKey: .amberRecipients)
        
        self.resolutionRate = container.decodeFlexibleDouble(forKey: .resolutionRate) ?? 0.0
        self.avgDaysToResolve = container.decodeFlexibleDouble(forKey: .avgDaysToResolve) ?? 0.0
        self.byCity = try? container.decodeIfPresent([CityCount].self, forKey: .byCity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalMissing, forKey: .totalMissing)
        try container.encode(totalFound, forKey: .totalFound)
        try container.encode(totalResolved, forKey: .totalResolved)
        try container.encode(totalVolunteers, forKey: .totalVolunteers)
        try container.encodeIfPresent(totalVisitors, forKey: .totalVisitors)
        try container.encodeIfPresent(currentlyActive, forKey: .currentlyActive)
        try container.encodeIfPresent(amberRecipients, forKey: .amberRecipients)
        try container.encode(resolutionRate, forKey: .resolutionRate)
        try container.encode(avgDaysToResolve, forKey: .avgDaysToResolve)
        try container.encodeIfPresent(byCity, forKey: .byCity)
    }

    private enum RawStatsKeys: String, CodingKey {
        case totalVolunteersApproved = "total_volunteers_approved"
    }

    static let placeholder = PlatformStats(
        totalMissing: 0,
        totalFound: 0,
        totalResolved: 0,
        totalVolunteers: 0,
        resolutionRate: 0.0,
        avgDaysToResolve: 0.0,
        byCity: []
    )
}

struct CityCount: Codable, Identifiable {
    var id: String { city ?? UUID().uuidString }
    let city: String?
    let count: Int

    enum CodingKeys: String, CodingKey {
        case city, count
    }

    init(city: String?, count: Int) {
        self.city = city
        self.count = count
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.city = try? container.decodeIfPresent(String.self, forKey: .city)
        self.count = container.decodeFlexibleInt(forKey: .count) ?? 0
    }
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

    init(
        id: Int,
        userId: Int? = nil,
        senderType: String = "user",
        senderName: String? = nil,
        message: String? = nil,
        attachmentUrl: String? = nil,
        attachmentType: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.senderType = senderType
        self.senderName = senderName
        self.message = message
        self.attachmentUrl = attachmentUrl
        self.attachmentType = attachmentType
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.userId = container.decodeFlexibleInt(forKey: .userId)
        self.senderType = (try? container.decodeIfPresent(String.self, forKey: .senderType)) ?? "user"
        self.senderName = try? container.decodeIfPresent(String.self, forKey: .senderName)
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        self.attachmentUrl = try? container.decodeIfPresent(String.self, forKey: .attachmentUrl)
        self.attachmentType = try? container.decodeIfPresent(String.self, forKey: .attachmentType)
        self.createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
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

    init(
        id: Int,
        userId: Int? = nil,
        fullName: String? = nil,
        city: String? = nil,
        skills: String? = nil,
        availabilityStatus: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.fullName = fullName
        self.city = city
        self.skills = skills
        self.availabilityStatus = availabilityStatus
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = container.decodeFlexibleInt(forKey: .id) ?? 0
        self.userId = container.decodeFlexibleInt(forKey: .userId)
        self.fullName = try? container.decodeIfPresent(String.self, forKey: .fullName)
        self.city = try? container.decodeIfPresent(String.self, forKey: .city)
        self.skills = try? container.decodeIfPresent(String.self, forKey: .skills)
        self.availabilityStatus = try? container.decodeIfPresent(String.self, forKey: .availabilityStatus)
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

    init(
        token: String = "",
        userId: Int = 0,
        name: String = "",
        email: String? = nil,
        phone: String? = nil,
        role: String = "volunteer",
        entityType: String? = nil
    ) {
        self.token = token
        self.userId = userId
        self.name = name
        self.email = email
        self.phone = phone
        self.role = role
        self.entityType = entityType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = (try? container.decodeIfPresent(String.self, forKey: .token)) ?? ""
        self.userId = container.decodeFlexibleInt(forKey: .userId) ?? 0
        self.name = (try? container.decodeIfPresent(String.self, forKey: .name)) ?? ""
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.phone = container.decodeFlexibleString(forKey: .phone)
        self.role = (try? container.decodeIfPresent(String.self, forKey: .role)) ?? "volunteer"
        self.entityType = try? container.decodeIfPresent(String.self, forKey: .entityType)
    }
}
