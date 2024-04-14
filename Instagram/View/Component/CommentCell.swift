//
//  CommentCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/29.
//

import UIKit
import SDWebImage

final class CommentCell: UITableViewCell {
    
    // MARK: - Properties
    
    var vm: CommentVM? {
        didSet { config() }
    }
    
    private lazy var commentID: String = ""
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12.5)
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var commentStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            usernameLabel,
            commentLabel
        ])
        
        view.axis = .vertical
        view.spacing = 8
        
        return view
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.style()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set

extension CommentCell {
    
    private func style() {
        self.selectionStyle = .none
        
        addSubview(profileImageView)
        addSubview(commentStackView)
        
        profileImageView.layer.cornerRadius = 35 / 2
    }
    
    private func layout() {
        profileImageView.setDimensions(height: 35, width: 35)
        
        profileImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 12,
            paddingLeft: 8
        )
        
        commentStackView.anchor(
            top: topAnchor,
            left: profileImageView.rightAnchor,
            right: rightAnchor,
            paddingTop: 12,
            paddingLeft: 12,
            paddingRight: 30
        )
    }
    
}

// MARK: - Helper Methods

extension CommentCell {
    
    private func config() {
        guard let vm = vm else { return }
        
        usernameLabel.text = vm.username
        commentLabel.text = vm.commentText
        
        profileImageView.sd_setImage(with: vm.profileImageUrl)
        
        commentID = vm.commentId
    }
    
}
