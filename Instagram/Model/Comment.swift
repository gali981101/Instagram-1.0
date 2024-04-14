//
//  Comment.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/31.
//

import Foundation

struct Comment {
    let commentId: String
    let uid: String
    let username: String
    let profileImageUrl: String
    let timestamp: Int
    let commentText: String
    
    // MARK: - init
    
    init(commentId: String, dict: [String: Any]) {
        self.commentId = commentId
        self.uid = dict[K.Comment.uid] as? String ?? ""
        self.username = dict[K.Comment.username] as? String ?? ""
        self.profileImageUrl = dict[K.Comment.profileImageUrl] as? String ?? ""
        self.timestamp = dict[K.Comment.timestamp] as? Int ?? Int(Date().timeIntervalSince1970 * 1000)
        self.commentText = dict[K.Comment.comment] as? String ?? ""
    }
}
