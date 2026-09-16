//
//  FamilyPortalViewModel.swift
//  WhereAreTheyiOS
//

import Foundation

@MainActor
class FamilyPortalViewModel: ObservableObject {
    @Published var searchCode: String = ""
    @Published var portalData: FamilyPortalData? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func search() async {
        let code = searchCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            errorMessage = "يرجى إدخال رمز البلاغ الموحد"
            return
        }
        
        isLoading = true
        errorMessage = nil
        portalData = nil
        
        do {
            self.portalData = try await APIService.shared.searchFamilyPortal(code: code)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
