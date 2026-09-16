//
//  NoticeListView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct NoticeListView: View {
    @StateObject private var viewModel = NoticesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.04, green: 0.06, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar
                    customHeader
                    
                    // Search & Filter Section
                    searchAndFilterBar
                    
                    // Content Feed
                    if viewModel.isLoading && viewModel.notices.isEmpty {
                        Spacer()
                        ProgressView("جاري تحميل البلاغات...")
                            .tint(.red)
                            .foregroundColor(.white)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("إعادة المحاولة") {
                                Task { await viewModel.loadNotices() }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        Spacer()
                    } else if viewModel.filteredNotices.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("🔍")
                                .font(.system(size: 48))
                            Text("لا توجد بلاغات تطابق البحث")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
                                ForEach(viewModel.filteredNotices) { notice in
                                    NavigationLink(destination: NoticeDetailView(noticeId: notice.id)) {
                                        NoticeCardView(notice: notice)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(16)
                        }
                        .refreshable {
                            await viewModel.loadNotices()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadNotices()
        }
    }
    
    private var customHeader: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 34, height: 34)
                    Text("🔍")
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("أين هم")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                    Text("المنصة الوطنية للبحث")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                Task { await viewModel.loadNotices() }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 10) {
            // Search Input Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("ابحث بالاسم، المدينة، أو الرمز...", text: $viewModel.searchQuery)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 14))
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 16)
            
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "الجميع", isSelected: viewModel.selectedTypeFilter == "all") {
                        viewModel.selectedTypeFilter = "all"
                    }
                    filterChip(title: "🔴 مفقودون", isSelected: viewModel.selectedTypeFilter == "missing") {
                        viewModel.selectedTypeFilter = "missing"
                    }
                    filterChip(title: "🟢 معثور عليهم", isSelected: viewModel.selectedTypeFilter == "found") {
                        viewModel.selectedTypeFilter = "found"
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 8)
    }
    
    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.red : Color.white.opacity(0.06))
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.red : Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }
}
