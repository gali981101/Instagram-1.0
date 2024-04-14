//
//  ProfileHeaderVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/17.
//

import UIKit

struct ProfileHeaderVM {
    var user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var editButtonText: String {
        if user.isCurrentUser {
            return K.ButtonTitle.editProfile
        }
        
        return user.isFollowed ? K.ButtonTitle.following : K.ButtonTitle.follow
    }
    
    var editButtonBGColor: UIColor {
        return user.isCurrentUser ? .systemBackground : ThemeColor.red3
    }
    
    var editButtonTextColor: UIColor {
        return user.isCurrentUser ? .label : .white
    }
    
    var numberOfFollowers: NSAttributedString {
        return LabelFactory.attributedStatText(
            value: user.stats.followers,
            label: K.Stats.followers
        )
    }
    
    var numberOfFollowing: NSAttributedString {
        return LabelFactory.attributedStatText(
            value: user.stats.followings,
            label: K.Stats.following
        )
    }
    
    var numberOfPosts: NSAttributedString {
        return LabelFactory.attributedStatText(
            value: user.stats.posts,
            label: K.Stats.posts
        )
    }
    
    // MARK: - init
    
    init(user: User) {
        self.user = user
    }
}
