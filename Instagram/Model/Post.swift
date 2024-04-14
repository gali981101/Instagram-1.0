//
//  Post.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/22.
//

import UIKit

struct Post {
    let postId: String
    var caption: String
    var captionHeight: CGFloat
    var isExpanded: Bool = false
    var likes: Int
    var didLike: Bool = false
    let imageUrls: [String]
    let ownerUid: String
    let timestamp: Int
    let ownerImageUrl: String
    let ownerUsername: String
    
    // MARK: - init
    
    init(postId: String, dict: [String: Any]) {
        self.postId = postId
        self.caption = dict[K.Post.caption] as? String ?? ""
        self.likes = dict[K.Post.likes] as? Int ?? 0
        self.imageUrls = dict[K.Post.imagesURL] as? [String] ?? []
        self.timestamp = dict[K.Post.timestamp] as? Int ?? Int(Date().timeIntervalSince1970 * 1000)
        self.ownerUid = dict[K.Post.ownerUid] as? String ?? ""
        self.ownerImageUrl = dict[K.Post.ownerImageUrl] as? String ?? ""
        self.ownerUsername = dict[K.Post.ownerUsername] as? String ?? ""
        
        self.captionHeight = caption.height(
            withWidth: UIScreen.main.bounds.width - 32,
            font: UIFont.systemFont(ofSize: 14)
        )
    }
}
 

