//
//  NoticeCardView.swift
//  WhereAreTheyiOS
//

import SwiftUI

struct NoticeCardView: View {
    let notice: Notice
    
    var body: some View {
        ModernNoticeCardView(notice: notice, onCardClick: {})
    }
}
