//
//  PostSettingVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/24.
//

import UIKit

// MARK: - Setting Items

private let postSettingItems1: [String] = [
    K.PostSetting.hideLikeCount,
    K.PostSetting.turnOffComment,
    K.PostSetting.edit,
    K.PostSetting.delete
]

private let postSettingImgs1: [UIImage?] = [
    UIImage(systemName: K.SystemImageName.heartSlash),
    UIImage(systemName: K.SystemImageName.circleSlash),
    UIImage(systemName: K.SystemImageName.pencil),
    UIImage(systemName: K.SystemImageName.trash)
]

private let postSettingItems2: [String] = [
    K.PostSetting.aboutAccount,
    K.PostSetting.notInterest
]

private let postSettingImgs2: [UIImage?] = [
    UIImage(systemName: K.SystemImageName.personCircle),
    UIImage(systemName: K.SystemImageName.eyeSlash)
]

// MARK: - PostSettingVM

struct PostSettingVM {
    let id: String
    
    var items: [String] {
        return AuthService.shared.getCurrentUserUid() == id ?
        postSettingItems1 : postSettingItems2
    }
    
    var images: [UIImage?] {
        return AuthService.shared.getCurrentUserUid() == id ?
        postSettingImgs1 : postSettingImgs2
    }
    
    var count: Int {
        items.count
    }
}






















