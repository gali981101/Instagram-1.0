//
//  UserCellVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/18.
//

import Foundation

struct UserCellVM {
    var user: User
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        return user.isFollowed ? K.ButtonTitle.following : K.ButtonTitle.follow
    }
    
    init(user: User) {
        self.user = user
    }
}
