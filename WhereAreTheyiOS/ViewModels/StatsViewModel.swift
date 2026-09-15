//
//  StatsViewModel.swift
//  WhereAreTheyiOS
//

import Foundation

@MainActor
class StatsViewModel: ObservableObject {
    @Published var stats: PlatformStats = PlatformStats.placeholder
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func loadStats() async {
        isLoading = true
        errorMessage = nil
        do {
            self.stats = try await APIService.shared.fetchStats()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
