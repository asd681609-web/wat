//
//  NoticeDetailView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Detailed Profile matching Android NoticeDetailScreen
//

import SwiftUI
import MapKit

struct NoticeDetailView: View {
    let noticeId: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var detailData: NoticeDetailData? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var showSubmitTip: Bool = false
    @State private var showShareSheet: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("جارِ استرجاع السجل والملف الطبي...")
                        .tint(AinTheme.cyan)
                } else if let data = detailData {
                    let notice = data.notice
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header Photo Box
                            headerPhotoSection(notice: notice)
                            
                            // Essential Emergency Actions (اتصال بالطوارئ 1515 + تقديم إفادة)
                            emergencyActionsSection(notice: notice)
                            
                            // Medical & Health Profile (الملف الطبي)
                            if notice.urgentMedicationRequired == 1 || notice.bloodType != nil || notice.specialNeeds != nil {
                                medicalProfileCard(notice: notice)
                            }
                            
                            // Physical Description & Clothing (الأوصاف الجسدية والملابس)
                            physicalDescriptionCard(notice: notice)
                            
                            // Last Known Location (Map preview)
                            if let coord = notice.coordinate {
                                locationMapCard(notice: notice, coordinate: coord)
                            }
                            
                            // Official Field Updates & Sightings
                            if let updates = data.adminUpdates, !updates.isEmpty {
                                adminUpdatesCard(updates: updates)
                            }
                            
                            Spacer().frame(height: 40)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(AinTheme.amber)
                        Text(errorMessage ?? "تعذر جلب تفاصيل البلاغ")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AinTheme.textSecondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AinTheme.textMuted)
                            .font(.system(size: 20))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("ملف البلاغ الرسمي")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AinTheme.textPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AinTheme.cyan)
                    }
                }
            }
        }
        .sheet(isPresented: $showSubmitTip) {
            if let notice = detailData?.notice {
                SubmitTipView(noticeCode: notice.uniqueCode)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let notice = detailData?.notice {
                let shareText = "بلاغ عن \(notice.displayName) - رمز: \(notice.uniqueCode)\nالرجاء المساعدة والاتصال بالطوارئ 1515 أو عبر منصة أين هم: https://wat.org.ly"
                ActivityView(activityItems: [shareText])
            }
        }
        .onAppear {
            loadNoticeDetail()
        }
    }
    
    private func loadNoticeDetail() {
        isLoading = true
        Task {
            do {
                let data = try await APIService.shared.fetchNoticeDetail(id: noticeId)
                await MainActor.run {
                    self.detailData = data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Header Photo Section
    private func headerPhotoSection(notice: Notice) -> some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                if let photoURL = notice.fullPhotoURL {
                    AsyncImage(url: photoURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                                .cornerRadius(20)
                        default:
                            placeholderHeader
                        }
                    }
                } else {
                    placeholderHeader
                }
                
                // Status Badge Overlay
                Text(notice.isMissing ? "مفقود 🚨" : "معثور عليه ✅")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(notice.isMissing ? AinTheme.red : AinTheme.emerald)
                    .cornerRadius(10)
                    .padding(14)
            }
            .padding(.horizontal, 16)
            
            // Name & Code
            VStack(spacing: 4) {
                Text(notice.displayName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(AinTheme.textPrimary)
                
                Text("رمز البلاغ الموحد: #\(notice.uniqueCode)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AinTheme.cyan)
            }
        }
    }

    private var placeholderHeader: some View {
        Rectangle()
            .fill(AinTheme.bgTertiary)
            .frame(height: 220)
            .cornerRadius(20)
            .overlay(
                Image(systemName: "person.crop.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AinTheme.textMuted)
            )
    }

    // MARK: - Emergency Action Buttons
    private func emergencyActionsSection(notice: Notice) -> some View {
        VStack(spacing: 10) {
            // Primary Call 1515 Button
            Button(action: {
                if let url = URL(string: "tel://1515") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                    Text("اتصال فوري بغرفة طوارئ 1515")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AinTheme.red)
                .cornerRadius(14)
                .shadow(color: AinTheme.redGlow, radius: 4, x: 0, y: 2)
            }
            
            // Submit Field Tip Button
            Button(action: { showSubmitTip = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 16))
                    Text("تقديم إفادة أو مشاهدة ميدانية سرية")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(AinTheme.cyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AinTheme.cyanSurface)
                .cornerRadius(14)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AinTheme.cyan.opacity(0.3), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Medical Profile Card
    private func medicalProfileCard(notice: Notice) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "cross.case.fill")
                    .foregroundColor(AinTheme.red)
                Text("الملف الطبي والحالات الحرجة")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AinTheme.textPrimary)
            }
            
            Divider().background(AinTheme.divider)
            
            if let blood = notice.bloodType, !blood.isEmpty {
                infoRow(title: "فصيلة الدم:", value: blood)
            }
            if let med = notice.medicationName, !med.isEmpty {
                infoRow(title: "أدوية ملحة:", value: med)
            }
            if let needs = notice.specialNeeds, !needs.isEmpty {
                infoRow(title: "احتياجات خاصة:", value: needs)
            }
        }
        .padding(14)
        .background(AinTheme.bgSecondary)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.redLight.opacity(0.3), lineWidth: 1))
        .padding(.horizontal, 16)
    }

    // MARK: - Physical Description Card
    private func physicalDescriptionCard(notice: Notice) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.text.rectangle.fill")
                    .foregroundColor(AinTheme.cyan)
                Text("المواصفات الجسدية والعلامات المميزة")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AinTheme.textPrimary)
            }
            
            Divider().background(AinTheme.divider)
            
            if let height = notice.heightCm, !height.isEmpty {
                infoRow(title: "الطول التقريبي:", value: "\(height) سم")
            }
            if let eye = notice.eyeColor, !eye.isEmpty {
                infoRow(title: "لون العينين:", value: eye)
            }
            if let hair = notice.hairColor, !hair.isEmpty {
                infoRow(title: "لون الشعر:", value: hair)
            }
            if let clothes = notice.clothesDescription, !clothes.isEmpty {
                infoRow(title: "الملابس عند الاختفاء:", value: clothes)
            }
            if let desc = notice.description, !desc.isEmpty {
                infoRow(title: "تفاصيل الواقعة:", value: desc)
            }
        }
        .padding(14)
        .background(AinTheme.bgSecondary)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    // MARK: - Location Map Card
    private func locationMapCard(notice: Notice, coordinate: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(AinTheme.cyan)
                Text("آخر مكان شوهد فيه")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AinTheme.textPrimary)
            }
            
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )), annotationItems: [notice]) { item in
                MapMarker(coordinate: item.coordinate ?? coordinate, tint: item.isMissing ? .red : .green)
            }
            .frame(height: 160)
            .cornerRadius(12)
        }
        .padding(14)
        .background(AinTheme.bgSecondary)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    // MARK: - Admin Updates Card
    private func adminUpdatesCard(updates: [AdminUpdateItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(AinTheme.amber)
                Text("تحديثات غرفة العمليات الرسمية")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AinTheme.textPrimary)
            }
            
            Divider().background(AinTheme.divider)
            
            ForEach(updates) { update in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(update.title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AinTheme.textPrimary)
                        Spacer()
                        if let date = update.createdAt {
                            Text(date)
                                .font(.system(size: 10))
                                .foregroundColor(AinTheme.textMuted)
                        }
                    }
                    Text(update.content)
                        .font(.system(size: 12))
                        .foregroundColor(AinTheme.textSecondary)
                }
                .padding(10)
                .background(AinTheme.bgTertiary)
                .cornerRadius(10)
            }
        }
        .padding(14)
        .background(AinTheme.bgSecondary)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AinTheme.border, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AinTheme.textSecondary)
                .frame(width: 130, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(AinTheme.textPrimary)
            Spacer()
        }
    }
}

// Helper for UIActivityViewController (ShareSheet)
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
