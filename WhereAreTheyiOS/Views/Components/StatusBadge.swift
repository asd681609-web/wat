//
//  StatusBadge.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct StatusBadge: View {
    let type: String // "missing" or "found"
    
    var isMissing: Bool { type == "missing" }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isMissing ? Color.red : Color.green)
                .frame(width: 6, height: 6)
            
            Text(isMissing ? "مفقود" : "معثور عليه")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isMissing ? Color(red: 0.94, green: 0.27, blue: 0.27) : Color(red: 0.13, green: 0.77, blue: 0.37))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (isMissing ? Color.red : Color.green).opacity(0.12)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke((isMissing ? Color.red : Color.green).opacity(0.3), lineWidth: 1)
        )
    }
}
