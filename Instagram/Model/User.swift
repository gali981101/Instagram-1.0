//
//  User.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/17.
//

import Foundation
// import Firebase

// MARK: - User

struct User {
    
    // MARK: - Properties
    
    let email: String
    let fullname: String
    let profileImageUrl: String
    let username: String
    let uid: String
    
    var isFollowed: Bool = false
    
    var isCurrentUser: Bool {
        return AuthService.shared.getCurrentUserUid() == uid
    }
    
    var stats: UserStats!
    
    // MARK: - init
    
    init(dict: [String: Any]) {
        self.email = dict[K.UserProfile.email] as? String ?? ""
        self.fullname = dict[K.UserProfile.fullname] as? String ?? ""
        self.profileImageUrl = dict[K.UserProfile.profileImageUrl] as? String ?? ""
        self.username = dict[K.UserProfile.username] as? String ?? ""
        self.uid = dict[K.UserProfile.uid] as? String ?? ""
        
        self.stats = UserStats(followers: 0, followings: 0, posts: 0)
    }
    
}

// MARK: - User Stats

struct UserStats {
    let followers: Int
    let followings: Int
    let posts: Int
}

