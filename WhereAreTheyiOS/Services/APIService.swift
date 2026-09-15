//
//  APIService.swift
//  WhereAreTheyiOS
//
//  Created for AinHum (أين هم) Platform.
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
            return "خطأ في قراءة بيانات الخادم: \(err.localizedDescription)"
        case .networkError(let err):
            return "تعذر الاتصال بالشبكة: \(err.localizedDescription)"
        }
    }
}

actor APIService {
    static let shared = APIService()
    
    private let baseURL = "https://wat.org.ly/api/mobile/"
    private let legacyBaseURL = "https://wat.org.ly/api/"
    
    var userToken: String? = nil
    
    private init() {}
    
    // MARK: - Fetch Active Notices
    func fetchNotices(type: String? = nil, city: String? = nil) async throws -> [Notice] {
        var components = URLComponents(string: baseURL + "map-notices.php")
        var queryItems: [URLQueryItem] = []
        if let type = type, !type.isEmpty {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        if let city = city, !city.isEmpty {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }
        components?.queryItems = queryItems
        
        guard let url = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = userToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError("استجابة الخادم غير ناجحة")
            }
            
            let decoded = try JSONDecoder().decode(ApiResponse<[Notice]>.self, from: data)
            return decoded.data ?? []
        } catch let err as APIError {
            throw err
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Fetch Platform Stats
    func fetchStats() async throws -> PlatformStats {
        guard let url = URL(string: baseURL + "platform-stats.php") else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ApiResponse<PlatformStats>.self, from: data)
        return decoded.data ?? PlatformStats.placeholder
    }
    
    // MARK: - Search Family Portal
    func searchFamilyPortal(code: String) async throws -> FamilyPortalResponse {
        var components = URLComponents(string: baseURL + "family-portal.php")
        components?.queryItems = [URLQueryItem(name: "code", value: code)]
        
        guard let url = components?.url else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ApiResponse<FamilyPortalResponse>.self, from: data)
        if let res = decoded.data {
            return res
        }
        throw APIError.serverError(decoded.message ?? "لم يتم العثور على البلاغ")
    }
    
    // MARK: - Fetch Volunteers
    func fetchVolunteers(city: String? = nil) async throws -> [VolunteerItem] {
        var components = URLComponents(string: baseURL + "volunteers.php")
        if let city = city, !city.isEmpty {
            components?.queryItems = [URLQueryItem(name: "city", value: city)]
        }
        guard let url = components?.url else { throw APIError.invalidURL }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ApiResponse<[VolunteerItem]>.self, from: data)
        return decoded.data ?? []
    }
    
    // MARK: - Submit Field Tip
    func submitTip(noticeCode: String, content: String, location: String, phone: String) async throws -> String {
        guard let url = URL(string: legacyBaseURL + "tips.php") else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "notice_code=\(noticeCode)&content=\(content)&location_description=\(location)&contact_phone=\(phone)"
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let msg = json["message"] as? String {
            return msg
        }
        return "تم إرسال الإفادة بنجاح"
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
