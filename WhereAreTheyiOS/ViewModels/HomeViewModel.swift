//
//  HomeViewModel.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Home State Management matching Android
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var notices: [Notice] = []
    @Published var filteredNotices: [Notice] = []
    @Published var amberAlerts: [AmberAlert] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var searchQuery: String = ""
    @Published var selectedType: String = "all" // "all", "missing", "found", "deceased"
    @Published var selectedCity: String = "كل المدن"

    let cities = ["كل المدن", "طرابلس", "بنغازي", "مصراتة", "الزاوية", "سبها", "سرت", "البيضاء", "طبرق", "زليتن", "درنة"]

    func loadData() {
        Task {
            await refresh()
        }
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        do {
            async let noticesTask = APIService.shared.fetchNotices(limit: 50)
            async let alertsTask = APIService.shared.fetchAmberAlerts()
            
            let (fetchedNotices, fetchedAlerts) = try await (noticesTask, alertsTask)
            self.notices = fetchedNotices
            self.amberAlerts = fetchedAlerts
            filterNotices()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func filterNotices() {
        var results = notices
        
        // Filter by type
        if selectedType != "all" {
            results = results.filter { $0.type == selectedType }
        }
        
        // Filter by city
        if selectedCity != "كل المدن" {
            results = results.filter { $0.city == selectedCity }
        }
        
        // Filter by search query
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchQuery.lowercased()
            results = results.filter {
                ($0.fullName?.lowercased().contains(q) ?? false) ||
                ($0.uniqueCode.lowercased().contains(q)) ||
                ($0.city?.lowercased().contains(q) ?? false) ||
                ($0.district?.lowercased().contains(q) ?? false) ||
                ($0.description?.lowercased().contains(q) ?? false)
            }
        }
        
        self.filteredNotices = results
    }
}
