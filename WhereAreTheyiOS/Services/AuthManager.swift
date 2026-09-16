//
//  AuthManager.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Session and Auth State Manager
//

import Foundation
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isLoggedIn: Bool = false
    @Published var token: String? = nil
    @Published var userId: Int? = nil
    @Published var userName: String = "مستخدم"
    @Published var userRole: String = "citizen" // "citizen", "volunteer", "hospital", "border", "admin"
    @Published var userCity: String = "طرابلس"
    @Published var entityType: String = ""

    private let kToken = "ain_user_token"
    private let kUserId = "ain_user_id"
    private let kUserName = "ain_user_name"
    private let kUserRole = "ain_user_role"
    private let kUserCity = "ain_user_city"
    private let kEntityType = "ain_entity_type"

    private init() {
        loadSession()
    }

    func loadSession() {
        let def = UserDefaults.standard
        if let savedToken = def.string(forKey: kToken), !savedToken.isEmpty {
            self.token = savedToken
            self.isLoggedIn = true
            self.userId = def.integer(forKey: kUserId)
            self.userName = def.string(forKey: kUserName) ?? "مستخدم"
            self.userRole = def.string(forKey: kUserRole) ?? "citizen"
            self.userCity = def.string(forKey: kUserCity) ?? "طرابلس"
            self.entityType = def.string(forKey: kEntityType) ?? ""
        } else {
            self.isLoggedIn = false
            self.token = nil
            self.userId = nil
        }
    }

    func saveSession(token: String, userId: Int, name: String, role: String, entityType: String?, city: String = "طرابلس") {
        let def = UserDefaults.standard
        def.set(token, forKey: kToken)
        def.set(userId, forKey: kUserId)
        def.set(name, forKey: kUserName)
        def.set(role, forKey: kUserRole)
        def.set(city, forKey: kUserCity)
        def.set(entityType ?? "", forKey: kEntityType)

        self.token = token
        self.userId = userId
        self.userName = name
        self.userRole = role
        self.userCity = city
        self.entityType = entityType ?? ""
        self.isLoggedIn = true
    }

    func logout() {
        let def = UserDefaults.standard
        def.removeObject(forKey: kToken)
        def.removeObject(forKey: kUserId)
        def.removeObject(forKey: kUserName)
        def.removeObject(forKey: kUserRole)
        def.removeObject(forKey: kUserCity)
        def.removeObject(forKey: kEntityType)

        self.token = nil
        self.userId = nil
        self.userName = "مستخدم"
        self.userRole = "citizen"
        self.isLoggedIn = false
    }
}
