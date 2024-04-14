//
//  NotificationCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/4.
//

import UIKit
import SDWebImage

// MARK: - NotificationCellDelegate

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String, isNotify: Bool)
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String, isNotify: Bool)
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String)
}

// MARK: - NotificationCell

final class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var isNotify: Bool?
    
    var notificationVM: NotificationVM? {
        didSet { config1() }
    }
    
    var userCellVM: UserCellVM? {
        didSet { config2() }
    }
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFit
        
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        
        iv.layer.cornerRadius = 5
        iv.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handlePostTapped)
        )
        
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.loading, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        
        button.addTarget(
            self,
            action: #selector(handleFollowTapped),
            for: .touchUpInside
        )
        
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set

extension NotificationCell {
    
    private func configUI() {
        selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        
        addSubview(profileImageView)
        addSubview(infoLabel)
        addSubview(followButton)
        addSubview(postImageView)
        
        profileImageView.layer.cornerRadius = 48 / 2
        
        followButton.backgroundColor = ThemeColor.red3
        followButton.setTitleColor(.white, for: .normal)
    }
    
    private func layout() {
        profileImageView.setDimensions(height: 48, width: 48)
        
        profileImageView.centerY(
            inView: self,
            leftAnchor: leftAnchor,
            paddingLeft: 12
        )
        
        followButton.centerY(inView: self)
        
        followButton.anchor(
            right: rightAnchor,
            paddingRight: 15,
            width: 88,
            height: 32
        )
        
        postImageView.centerY(inView: self)
        
        postImageView.anchor(
            right: rightAnchor,
            paddingRight: 15,
            width: 40,
            height: 40
        )
        
        infoLabel.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
        
        infoLabel.anchor(
            right: followButton.leftAnchor,
            paddingRight: 4
        )
    }
    
}

// MARK: - @objc Actions

extension NotificationCell {
    
    @objc private func handleFollowTapped() {
        guard let isNotify = isNotify else { return }
        followButton.giveFeedback()
        
        if isNotify {
            handleNotificationFollow()
        } else {
            handleSuggestedFollow()
        }
    }
    
    @objc private func handlePostTapped() {
        guard let postId = notificationVM?.notify.postId else { return }
        delegate?.cell(self, wantsToViewPost: postId)
    }
    
}

// MARK: - Helper Methods

extension NotificationCell {
    
    private func config1() {
        guard let vm = notificationVM else { return }
        
        profileImageView.sd_setImage(with: vm.profileImageUrl)
        postImageView.sd_setImage(with: vm.postImageUrl)
        
        infoLabel.attributedText = vm.notificationMessage
        
        followButton.isHidden = !vm.shouldHidePostImage
        postImageView.isHidden = vm.shouldHidePostImage
        
        followButton.setTitle(vm.followButtonText, for: .normal)
    }
    
    private func config2() {
        guard let vm = userCellVM else { return }
        
        profileImageView.sd_setImage(with: vm.profileImageUrl)
        infoLabel.text = vm.username
        
        postImageView.isHidden = true
        followButton.isHidden = false
        
        followButton.setTitle(vm.followButtonText, for: .normal)
    }
    
    private func handleNotificationFollow() {
        guard let vm = notificationVM else { return }
        
        if vm.notify.userIsFollowed {
            delegate?.cell(self, wantsToUnfollow: vm.notify.uid, isNotify: true)
        } else {
            delegate?.cell(self, wantsToFollow: vm.notify.uid, isNotify: true)
        }
    }
    
    private func handleSuggestedFollow() {
        guard let vm = userCellVM else { return }
        
        if vm.user.isFollowed {
            delegate?.cell(self, wantsToUnfollow: vm.user.uid, isNotify: false)
        } else {
            delegate?.cell(self, wantsToFollow: vm.user.uid, isNotify: false)
        }
    }
    
}























