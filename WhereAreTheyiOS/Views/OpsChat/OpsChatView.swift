//
//  OpsChatView.swift
//  WhereAreTheyiOS
//
//  Created for AinHum Platform (أين هم) — Live Operations Chat matching Android OpsChatScreen
//

import SwiftUI

struct OpsChatView: View {
    @State private var messages: [OpsChatMessage] = []
    @State private var inputMessage: String = ""
    @State private var isSending: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AinTheme.bgPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Operational Status Header
                    operationalHeader
                    
                    // Messages Stream
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { msg in
                                    chatBubble(msg: msg)
                                        .id(msg.id)
                                }
                                Spacer().frame(height: 10)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        }
                        .onChange(of: messages.count) { _ in
                            if let last = messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }
                    
                    // Bottom Spacing for Floating Tab Bar
                    inputMessageBar
                        .padding(.bottom, 80)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "headphones.circle.fill")
                            .foregroundColor(AinTheme.cyan)
                            .font(.system(size: 18))
                        Text("غرفة العمليات والنداء")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AinTheme.textPrimary)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadMessages()
        }
    }

    // Operational Header
    private var operationalHeader: some View {
        HStack {
            Circle()
                .fill(AinTheme.emerald)
                .frame(width: 8, height: 8)
            Text("غرفة العمليات المركزية 1515 • متصل ومستعد للبلاغات")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AinTheme.emeraldDark)
            Spacer()
            Button(action: loadMessages) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 13))
                    .foregroundColor(AinTheme.textMuted)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AinTheme.emeraldSurface)
    }

    // Chat Bubble
    private func chatBubble(msg: OpsChatMessage) -> some View {
        HStack {
            if !msg.isFromOps { Spacer() }
            
            VStack(alignment: msg.isFromOps ? .leading : .trailing, spacing: 4) {
                if msg.isFromOps {
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AinTheme.cyan)
                        Text(msg.senderName ?? "عمليات الطوارئ 1515")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AinTheme.cyan)
                    }
                }
                
                Text(msg.message ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(msg.isFromOps ? AinTheme.textPrimary : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(msg.isFromOps ? AinTheme.bgSecondary : AinTheme.cyan)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                
                if let date = msg.createdAt {
                    Text(date)
                        .font(.system(size: 9))
                        .foregroundColor(AinTheme.textMuted)
                }
            }
            .frame(maxWidth: 280, alignment: msg.isFromOps ? .leading : .trailing)
            
            if msg.isFromOps { Spacer() }
        }
    }

    // Input Bar
    private var inputMessageBar: some View {
        HStack(spacing: 10) {
            TextField("اكتب رسالتك لغرفة العمليات...", text: $inputMessage)
                .font(.system(size: 13))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AinTheme.bgTertiary)
                .cornerRadius(20)
            
            Button(action: sendMessage) {
                ZStack {
                    Circle()
                        .fill(inputMessage.trimmingCharacters(in: .whitespaces).isEmpty ? AinTheme.textMuted : AinTheme.cyan)
                        .frame(width: 40, height: 40)
                    
                    if isSending {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(inputMessage.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background(AinTheme.bgSecondary)
    }

    private func loadMessages() {
        Task {
            do {
                let list = try await APIService.shared.fetchOpsMessages()
                await MainActor.run {
                    if list.isEmpty {
                        // Default welcome message from ops
                        self.messages = [
                            OpsChatMessage(
                                id: 1,
                                userId: 0,
                                senderType: "ops",
                                senderName: "غرفة العمليات المركزية 1515",
                                message: "مرحباً بك في قناة العمليات المباشرة. يمكنك إرسال أية إفادات عاجلة، أو الاستفسار عن حالات المفقودين هنا وسيقوم ضابط العمليات بالرد عليك فوراً.",
                                attachmentUrl: nil,
                                attachmentType: nil,
                                createdAt: "الآن"
                            )
                        ]
                    } else {
                        self.messages = list
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }

    private func sendMessage() {
        let text = inputMessage.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        
        // Optimistic local add
        let localMsg = OpsChatMessage(
            id: Int.random(in: 1000...99999),
            userId: AuthManager.shared.userId,
            senderType: "user",
            senderName: AuthManager.shared.userName,
            message: text,
            attachmentUrl: nil,
            attachmentType: nil,
            createdAt: "الآن"
        )
        messages.append(localMsg)
        inputMessage = ""
        isSending = true
        
        Task {
            _ = try? await APIService.shared.sendOpsMessage(message: text)
            await MainActor.run { isSending = false }
        }
    }
}
