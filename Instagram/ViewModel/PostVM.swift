//
//  PostVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/22.
//

import UIKit

struct PostVM {
    var post: Post
    
    let indexPath: IndexPath
    
    var ownerUid: String {
        return post.ownerUid
    }
    
    var ownerImageUrl: URL? {
        return URL(string: post.ownerImageUrl)
    }
    
    var ownerUsername: String {
        return post.ownerUsername
    }
    
    var postId: String {
        return post.postId
    }
    
    var imageUrls: [URL]? {
        return post.imageUrls.map { URL(string: $0)! }
    }
    
    var caption: String {
        return post.caption
    }
    
    var likes: Int {
        return post.likes
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .red : .label
    }
    
    var likeButtonImage: UIImage? {
        let imageName: String = post.didLike ? K.SystemImageName.heartFill : K.SystemImageName.heart
        return UIImage(systemName: imageName)
    }
    
    var likesLabelText: String {
        return post.likes != 1 ? "\(post.likes) likes" : "\(post.likes) like"
    }
    
    var captionHeight: CGFloat {
        return post.captionHeight
    }
    
    var timestampString: String? {
        // 將毫秒轉換為秒
        let timestampSeconds = TimeInterval(post.timestamp / 1000)
        
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
    
    // MARK: - init
    
    init(post: Post, indexPath: IndexPath) {
        self.post = post
        self.indexPath = indexPath
    }
}














