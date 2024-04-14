//
//  NotificationVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/5.
//

import UIKit

struct NotificationVM {
    
    var notify: Notify
    
    var profileImageUrl: URL? {
        return URL(string: notify.userProfileImageUrl)
    }
    
    var postImageUrl: URL? {
        return URL(string: notify.postImageUrl ?? "")
    }
    
    var timestampString: String? {
        // 將毫秒轉換為秒
        let timestampSeconds = TimeInterval(notify.timestamp / 1000)
        
        // 創建 Date 物件
        let date = Date(timeIntervalSince1970: timestampSeconds)
        
        // 計算日期之間的時間間隔
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())
        
        // 檢查最大的時間單位並格式化時間間隔
        if let years = interval.year, years > 0 {
            return "\(years) year"
        } else if let months = interval.month, months > 0 {
            return "\(months) month"
        } else if let days = interval.day, days > 0 {
            return "\(days) day"
        } else if let hours = interval.hour, hours > 0 {
            return "\(hours) hour"
        } else if let minutes = interval.minute, minutes > 0 {
            return "\(minutes) min"
        } else if let seconds = interval.second {
            return "\(seconds) second"
        } else {
            return "just now"
            
        }
    }
    
    var notificationMessage: NSAttributedString {
        let username = notify.username
        let message = notify.type.notifyMessage
        
        let attributedText = NSMutableAttributedString(
            string: username,
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        
        attributedText.append(NSAttributedString(
            string: message,
            attributes: [.font: UIFont.systemFont(ofSize: 14)]
        ))
        
        attributedText.append(NSAttributedString(
            string: "  \(timestampString ?? "2m")",
            attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]
        ))
        
        return attributedText
        
    }
    
    var shouldHidePostImage: Bool {
        return notify.type == .follow
    }
    
    var followButtonText: String {
        return notify.userIsFollowed ? K.ButtonTitle.following : K.ButtonTitle.follow
    }
    
    // MARK: - init
    
    init(notify: Notify) {
        self.notify = notify
    }
    
}
