//
//  APIService.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Complete Networking Engine matching Android & Backend
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "رابط الاتصال بالخادم غير صحيح"
        case .serverError(let msg):
            return msg
        case .decodingError(let err):
            return "خطأ في معالجة بيانات الخادم: \(err.localizedDescription)"
        case .networkError(let err):
            return "تعذر الاتصال بالشبكة: \(err.localizedDescription)"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://wat.org.ly/api/mobile/"
    private let legacyBaseURL = "https://wat.org.ly/api/"
    
    private init() {}
    
    private func authHeader() -> [String: String] {
        var headers: [String: String] = [:]
        if let token = AuthManager.shared.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    // MARK: - Register Device for Push / Emergency Alerts
    func registerDevice(fcmToken: String, city: String?, lat: Double?, lng: Double?, deviceOs: String = "ios") async throws {
        guard let url = URL(string: baseURL + "register-device.php") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authHeader().forEach { request.setValue($1, forHTTPHeaderField: $0) }

        var payload: [String: Any] = [
            "fcm_token": fcmToken,
            "device_os": deviceOs
        ]
        if let city = city, !city.isEmpty { payload["city"] = city }
        if let lat = lat { payload["lat"] = lat }
        if let lng = lng { payload["lng"] = lng }
        if let userId = AuthManager.shared.userId { payload["user_id"] = userId }

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.serverError("تعذر تسجيل الجهاز في مركز الإشعارات")
        }
        print("Device registration response: \(data.count) bytes")
    }

    // MARK: - Fetch Notices with Filters & Pagination
    func fetchNotices(
        type: String? = nil,
        city: String? = nil,
        query: String? = nil,
        status: String? = nil,
        page: Int = 1,
        limit: Int = 50
    ) async throws -> [Notice] {
        var components = URLComponents(string: baseURL + "get-notices.php")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let type = type, !type.isEmpty, type != "all" {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        if let city = city, !city.isEmpty, city != "كل المدن" {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        if let status = status, !status.isEmpty {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        // Pass user coordinates if available to calculate real distance_km
        if let loc = LocationManager.shared.userLocation {
            queryItems.append(URLQueryItem(name: "lat", value: "\(loc.latitude)"))
            queryItems.append(URLQueryItem(name: "lng", value: "\(loc.longitude)"))
        }

        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        authHeader().forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw APIError.serverError("تعذر تحميل قائمة البلاغات من الخادم")
            }
            
            // First decode standard NoticesData container
            do {
                let decoded = try JSONDecoder().decode(ApiResponse<NoticesData>.self, from: data)
                if let items = decoded.data?.items {
                    return items
                }
            } catch {
                // Fallback: direct array decode
                if let decodedArray = try? JSONDecoder().decode(ApiResponse<[Notice]>.self, from: data),
                   let items = decodedArray.data {
                    return items
                }
                print("⚠️ Notices decoding error: \(error)")
                throw APIError.decodingError(error)
            }
            return []
        } catch let err as APIError {
            throw err
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Fetch Notice Detail
    func fetchNoticeDetail(id: Int) async throws -> NoticeDetailData {
        var components = URLComponents(string: baseURL + "notice-detail.php")
        components?.queryItems = [URLQueryItem(name: "id", value: "\(id)")]
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        authHeader().forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(ApiResponse<NoticeDetailData>.self, from: data)
        guard let result = decoded.data else {
            throw APIError.serverError(decoded.message ?? "لم يتم العثور على تفاصيل البلاغ")
        }
        return result
    }
    
    // MARK: - Fetch AMBER Alerts (Active Emergency Broadcasts)
    func fetchAmberAlerts(city: String = "") async throws -> [AmberAlert] {
        var components = URLComponents(string: baseURL + "get-amber-alerts.php")
        if !city.isEmpty && city != "كل المدن" {
            components?.queryItems = [URLQueryItem(name: "city", value: city)]
        }
        guard let url = components?.url else { return [] }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decoded = try? JSONDecoder().decode(ApiResponse<AmberAlertData>.self, from: data),
               let alerts = decoded.data?.alerts {
                return alerts
            }
            if let decodedArr = try? JSONDecoder().decode(ApiResponse<[AmberAlert]>.self, from: data),
               let alerts = decodedArr.data {
                return alerts
            }
            return []
        } catch {
            print("⚠️ fetchAmberAlerts error: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Map Notices (GPS coordinates)
    func fetchMapNotices() async throws -> [Notice] {
        guard let url = URL(string: baseURL + "map-notices.php") ?? URL(string: baseURL + "get-map-notices.php") else {
            throw APIError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let decoded = try JSONDecoder().decode(ApiResponse<[Notice]>.self, from: data)
            return decoded.data ?? []
        } catch {
            print("⚠️ fetchMapNotices decoding error: \(error)")
            return []
        }
    }
    
    // MARK: - Fetch Live Platform Stats
    func fetchStats() async throws -> PlatformStats {
        guard let url = URL(string: baseURL + "platform-stats.php") else { throw APIError.invalidURL }
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let decoded = try JSONDecoder().decode(ApiResponse<PlatformStats>.self, from: data)
            if let stats = decoded.data {
                return stats
            }
            return PlatformStats.placeholder
        } catch {
            print("⚠️ fetchStats decoding error: \(error)")
            return PlatformStats.placeholder
        }
    }
    
    // MARK: - Search Family Portal
    func searchFamilyPortal(code: String) async throws -> FamilyPortalData {
        var components = URLComponents(string: baseURL + "family-portal.php")
        components?.queryItems = [URLQueryItem(name: "code", value: code)]
        guard let url = components?.url else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ApiResponse<FamilyPortalData>.self, from: data)
        guard let portal = decoded.data else {
            throw APIError.serverError(decoded.message ?? "لم يتم العثور على بيانات بهذا الرمز")
        }
        return portal
    }
    
    // MARK: - Ops Chat: Fetch & Send Messages
    func fetchOpsMessages() async throws -> [OpsChatMessage] {
        let userId = AuthManager.shared.userId ?? 1
        var components = URLComponents(string: legacyBaseURL + "ops-chat.php")
        components?.queryItems = [URLQueryItem(name: "user_id", value: "\(userId)")]
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        authHeader().forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let messagesRaw = json["messages"] as? [[String: Any]] {
                let serialized = try JSONSerialization.data(withJSONObject: messagesRaw)
                return try JSONDecoder().decode([OpsChatMessage].self, from: serialized)
            }
            return []
        } catch {
            return []
        }
    }
    
    func sendOpsMessage(message: String) async throws -> Bool {
        guard let url = URL(string: legacyBaseURL + "ops-chat.php") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authHeader().forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let payload: [String: Any] = [
            "message": message,
            "sender_type": "user",
            "user_id": AuthManager.shared.userId ?? 1,
            "sender_name": AuthManager.shared.userName.isEmpty ? "مواطن" : AuthManager.shared.userName
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return (json["success"] as? Bool) ?? true
        }
        return true
    }
    
    // MARK: - Submit Field Tip (Confidential)
    func submitTip(noticeCode: String, content: String, location: String, phone: String) async throws -> String {
        guard let url = URL(string: baseURL + "submit-tip.php") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "notice_code": noticeCode,
            "content": content,
            "location_description": location,
            "contact_phone": phone
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let msg = json["message"] as? String {
            return msg
        }
        return "تم إرسال الإفادة بنجاح لغرفة العمليات"
    }

    // MARK: - Submit Notice Report
    func submitReport(
        type: String,
        fullName: String,
        age: String,
        city: String,
        district: String,
        description: String,
        contactPhone: String,
        specialNeeds: String?
    ) async throws -> String {
        guard let url = URL(string: baseURL + "submit-report.php") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        authHeader().forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let payload: [String: Any] = [
            "type": type,
            "full_name": fullName,
            "age": age,
            "city": city,
            "district": district,
            "description": description,
            "contact_phone": contactPhone,
            "special_needs": specialNeeds ?? ""
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let msg = json["message"] as? String {
            return msg
        }
        return "تم تسجيل البلاغ بنجاح"
    }
    
    // MARK: - Auth: Login
    func login(identifier: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: baseURL + "login.php") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["identifier": identifier, "password": password, "device_os": "ios"]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(ApiResponse<LoginResponse>.self, from: data)
        guard let loginData = decoded.data else {
            throw APIError.serverError(decoded.message ?? "فشل تسجيل الدخول، تحقق من البيانات")
        }
        return loginData
    }

    // MARK: - Update Volunteer Live GPS Location
    func updateVolunteerLocation(userId: Int?, name: String, phone: String, city: String, lat: Double, lng: Double, isOnline: Bool) async throws {
        guard let url = URL(string: legacyBaseURL + "update-volunteer-location.php") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "user_id": userId ?? 0,
            "name": name,
            "phone": phone,
            "city": city,
            "lat": lat,
            "lng": lng,
            "is_online": isOnline ? 1 : 0
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        _ = try await URLSession.shared.data(for: request)
    }
}