//
//  Notification.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/4.
//

import Foundation

enum NotifyType: Int {
    case like
    case follow
    case comment
    
    var notifyMessage: String {
        switch self {
        case .like:
            return " liked your post."
        case .follow:
            return " started following you."
        case .comment:
            return " commented on your post."
        }
    }
}

struct Notify {
    let id: String
    let uid: String
    let username: String
    let userProfileImageUrl: String
    var postId: String?
    var postImageUrl: String?
    let timestamp: Int
    let type: NotifyType
    var userIsFollowed: Bool = false
    
    // MARK: - init
    
    init(dict: [String: Any]) {
        self.id = dict[K.Notify.id] as? String ?? ""
        self.uid = dict[K.Notify.uid] as? String ?? ""
        self.username = dict[K.Notify.username] as? String ?? ""
        self.userProfileImageUrl = dict[K.Notify.userImageUrl] as? String ?? ""
        self.postId = dict[K.Notify.postId] as? String ?? ""
        self.postImageUrl = dict[K.Notify.postImageUrl] as? String ?? ""
        self.timestamp = dict[K.Notify.timestamp] as? Int ?? Int(Date().timeIntervalSince1970 * 1000)
        self.type = NotifyType(rawValue: dict[K.Notify.type] as? Int ?? 1) ?? .follow
    }
}
