//
//  AinTheme.swift
//  WhereAreTheyiOS
//
//  🎨 منصة «أين هم» — نظام الألوان والتصميم الموحد المتطابق مع تطبيق الأندرويد
//

import SwiftUI

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - AinTheme Unified Design Palette
struct AinTheme {
    // ── الخلفيات (Clean Light Mode) ───────────────────────────
    static let bgDeep        = Color(hex: "EDF2F7")
    static let bgPrimary     = Color(hex: "F8FAFC") // الخلفية الأساسية Off-White
    static let bgSecondary   = Color(hex: "FFFFFF") // خلفية البطاقات Pure White
    static let bgTertiary    = Color(hex: "F1F5F9") // خلفية العناصر الداخلية والمدخلات
    static let bgElevated    = Color(hex: "FFFFFF")

    // ── الألوان الأساسية ──────────────────────────────────────
    static let cyan          = Color(hex: "0284C7") // أزرق سماوي محترف — Accent
    static let cyanDark      = Color(hex: "0369A1")
    static let cyanLight     = Color(hex: "38BDF8")
    static let cyanSurface   = Color(hex: "0284C7").opacity(0.08)

    static let red           = Color(hex: "DC2626") // أحمر الطوارئ — Primary
    static let redDark       = Color(hex: "B91C1C")
    static let redLight      = Color(hex: "EF4444")
    static let redSurface    = Color(hex: "DC2626").opacity(0.08)
    static let redGlow       = Color(hex: "DC2626").opacity(0.2)

    static let emerald       = Color(hex: "16A34A") // أخضر زمردي — معثور عليه
    static let emeraldDark   = Color(hex: "15803D")
    static let emeraldLight  = Color(hex: "22C55E")
    static let emeraldSurface= Color(hex: "16A34A").opacity(0.08)

    static let amber         = Color(hex: "D97706") // كهرماني — AMBER Alert
    static let amberDark     = Color(hex: "B45309")
    static let amberLight    = Color(hex: "F59E0B")
    static let amberSurface  = Color(hex: "D97706").opacity(0.08)

    static let purple        = Color(hex: "7C3AED")
    static let blue          = Color(hex: "2563EB")

    // ── ألوان سارينة الشرطة (AMBER Siren) ────────────────────
    static let sirenRed      = Color(hex: "DC2626")
    static let sirenBlue     = Color(hex: "2563EB")
    static let sirenRedGlow  = Color(hex: "DC2626").opacity(0.3)
    static let sirenBlueGlow = Color(hex: "2563EB").opacity(0.3)

    // ── النصوص (Slate Hierarchy) ──────────────────────────────
    static let textPrimary   = Color(hex: "0F172A") // كحلي داكن مقروء جداً (Slate 900)
    static let textSecondary = Color(hex: "475569") // رمادي متوسط (Slate 600)
    static let textMuted     = Color(hex: "64748B") // رمادي باهت للأيقونات والتلميحات (Slate 500)
    static let textDisabled  = Color(hex: "94A3B8")

    // ── الفواصل والحدود ───────────────────────────────────────
    static let divider       = Color(hex: "E2E8F0")
    static let border        = Color(hex: "CBD5E1")
}
