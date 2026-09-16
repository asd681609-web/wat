//
//  NoticesViewModel.swift
//  WhereAreTheyiOS
//
//  Created for AinHum (أين هم) Platform.
//

import Foundation
import Combine

@MainActor
class NoticesViewModel: ObservableObject {
    @Published var notices: [Notice] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var searchQuery: String = ""
    @Published var selectedTypeFilter: String = "all" // "all", "missing", "found"
    @Published var selectedCityFilter: String = "all"
    
    var filteredNotices: [Notice] {
        return notices.filter { item in
            let matchesSearch = searchQuery.isEmpty ||
                (item.fullName?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                item.uniqueCode.localizedCaseInsensitiveContains(searchQuery) ||
                (item.city?.localizedCaseInsensitiveContains(searchQuery) ?? false)
            
            let matchesType = (selectedTypeFilter == "all") || (item.type == selectedTypeFilter)
            let matchesCity = (selectedCityFilter == "all") || (item.city == selectedCityFilter)
            
            return matchesSearch && matchesType && matchesCity
        }
    }
    
    var availableCities: [String] {
        let cities = notices.compactMap { $0.city }.filter { !$0.isEmpty }
        return Array(Set(cities)).sorted()
    }
    
    func loadNotices() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await APIService.shared.fetchNotices()
            self.notices = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
