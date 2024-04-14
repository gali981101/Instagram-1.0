//
//  CommentVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/31.
//

import UIKit

struct CommentVM {
    
    private let comment: Comment
    
    var profileImageUrl: URL? {
        return URL(string: comment.profileImageUrl)
    }
    
    var username: String {
        return comment.username
    }
    
    var commentText: String {
        return comment.commentText
    }
    
    var commentId: String {
        return comment.commentId
    }
    
    // MARK: - init
    
    init(comment: Comment) {
        self.comment = comment
    }
    
}

// MARK: - Methods

extension CommentVM {
    
    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.text = comment.commentText
        label.lineBreakMode = .byWordWrapping
        
        label.setWidth(width)
        
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
}













