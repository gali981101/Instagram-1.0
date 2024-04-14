//
//  ProfileHeader.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/14.
//

import UIKit
import SDWebImage

// MARK: - ProfileHeaderDelegate

protocol ProfileHeaderDelegate: AnyObject {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
    func showFollowerPage(uid: String, isFollowerPage: Bool)
    func didSelectItemAt(index: Int)
}

// MARK: - ProfileHeader

final class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var vm: ProfileHeaderVM? {
        didSet { configure() }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private var viewStyleButtons: [UIButton]!
    
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorTrailing: NSLayoutConstraint?
    
    private lazy var leadPadding: CGFloat = 0
    private lazy var buttonSpace: CGFloat = 0
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.backgroundColor = .lightGray
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .justified
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    private lazy var postsLabel: UILabel = LabelFactory
        .makeStatsLabel(number: 0, text: K.Stats.posts)
    
    private lazy var followersLabel: UILabel = LabelFactory
        .makeStatsLabel(number: 0, text: K.Stats.followers)
    
    private lazy var followingLabel: UILabel = LabelFactory
        .makeStatsLabel(number: 0, text: K.Stats.following)
    
    private lazy var labelStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            postsLabel,
            followersLabel,
            followingLabel
        ])
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        
        return view
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.loading, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        
        button.addTarget(
            self,
            action: #selector(handleEditFollowTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var messageShareProfileButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.shareProfile, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        
        button.addTarget(
            self,
            action: #selector(handleMessageShareTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var editShareButtonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            editProfileFollowButton,
            messageShareProfileButton
        ])
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 12
        
        return view
    }()
    
    private lazy var topDivider = UIView()
    
    private let gridButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(systemName: K.SystemImageName.gridFill),
            for: .normal
        )
        
        button.tintColor = .label
        
        return button
    }()
    
    private let personSquareButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(systemName: K.SystemImageName.personSquare),
            for: .normal
        )
        
        button.tintColor = .label
        
        return button
    }()
    
    private lazy var gridListButtonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            gridButton,
            personSquareButton
        ])
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        
        return view
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        viewStyleButtons = [gridButton, personSquareButton]
        
        super.init(frame: frame)
        
        gridButton.addTarget(
            self,
            action: #selector(handleGridButtonTapped),
            for: .primaryActionTriggered
        )
        
        personSquareButton.addTarget(
            self,
            action: #selector(handlePersonSquareButtonTapped),
            for: .primaryActionTriggered
        )
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set

extension ProfileHeader {
    
    private func style() {
        backgroundColor = .systemBackground
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(labelStackView)
        addSubview(editProfileFollowButton)
        addSubview(messageShareProfileButton)
        addSubview(editShareButtonStackView)
        addSubview(topDivider)
        addSubview(gridListButtonStackView)
        
        profileImageView.layer.cornerRadius = 80 / 2
        
        topDivider.backgroundColor = .lightGray
        
        setAlpha(for: gridButton)
        
        followersLabel.isUserInteractionEnabled = true
        followingLabel.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFollowerLabelTapped)
        )
        
        let tap2 = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFollowingLabelTapped)
        )
        
        followersLabel.addGestureRecognizer(tap1)
        followingLabel.addGestureRecognizer(tap2)
    }
    
    private func layout() {
        profileImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 16,
            paddingLeft: 30
        )
        
        profileImageView.setDimensions(height: 80, width: 80)
        
        nameLabel.anchor(
            top: profileImageView.bottomAnchor,
            left: leftAnchor,
            paddingTop: 12,
            paddingLeft: 40
        )
        
        labelStackView.centerY(inView: profileImageView)
        
        labelStackView.anchor(
            left: profileImageView.rightAnchor,
            right: rightAnchor,
            paddingLeft: 12,
            paddingRight: 12,
            height: 50
        )
        
        editShareButtonStackView.anchor(
            top: nameLabel.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 16,
            paddingLeft: 24,
            paddingRight: 24
        )
        
        topDivider.anchor(
            top: gridListButtonStackView.topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            height: 0.5
        )
        
        gridListButtonStackView.anchor(
            left: leftAnchor,
            bottom: bottomAnchor,
            right: rightAnchor,
            height: 50
        )
    }
    
}

// MARK: - @objc Actions

extension ProfileHeader {
    
    @objc private func handleFollowerLabelTapped() {
        guard let uid = vm?.user.uid else { return }
        delegate?.showFollowerPage(uid: uid, isFollowerPage: true)
    }
    
    @objc private func handleFollowingLabelTapped() {
        guard let uid = vm?.user.uid else { return }
        delegate?.showFollowerPage(uid: uid, isFollowerPage: false)
    }
    
    @objc private func handleEditFollowTapped() {
        guard let vm = vm else { return }
        delegate?.header(self, didTapActionButtonFor: vm.user)
    }
    
    @objc private func handleMessageShareTapped() {
    }
    
    @objc private func handleGridButtonTapped() {
        delegate?.didSelectItemAt(index: 0)
        setAlpha(for: gridButton)
        updateGridButton()
    }
    
    @objc private func handlePersonSquareButtonTapped() {
        delegate?.didSelectItemAt(index: 1)
        setAlpha(for: personSquareButton)
        updatePersonSquareButton()
    }
    
}

// MARK: - Helper Methods

extension ProfileHeader {
    
    private func configure() {
        guard var vm = vm else { return }
        
        nameLabel.text = vm.fullname
        
        editProfileFollowButton.backgroundColor = vm.editButtonBGColor
        
        editProfileFollowButton.setTitle(vm.editButtonText, for: .normal)
        editProfileFollowButton.setTitleColor(vm.editButtonTextColor, for: .normal)
        
        profileImageView.sd_setImage(with: vm.profileImageUrl) { image, error, _, url in
            if error != nil { fatalError(error.debugDescription) }
        }
        
        UserService.fetchUserStats(uid: vm.user.uid) { [unowned self] stats in
            vm.user.stats = stats
            
            postsLabel.attributedText = vm.numberOfPosts
            followersLabel.attributedText = vm.numberOfFollowers
            followingLabel.attributedText = vm.numberOfFollowing
        }
        
    }
    
    func selectItem(at index: Int) {
        animateIndicator(to: index)
    }
    
    private func animateIndicator(to index: Int) {
        
        var button: UIButton
        
        switch index {
        case 0:
            button = gridButton
        case 1:
            button = personSquareButton
        default:
            button = gridButton
        }
        
        setAlpha(for: button)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    private func setAlpha(for button: UIButton) {
        gridButton.alpha = 0.5
        personSquareButton.alpha = 0.5
        
        button.alpha = 1.0
    }
    
    private func updateGridButton() {
        gridButton.setImage(
            UIImage(systemName: K.SystemImageName.gridFill),
            for: .normal
        )
        
        personSquareButton.setImage(
            UIImage(systemName: K.SystemImageName.personSquare),
            for: .normal
        )
    }
    
    private func updatePersonSquareButton() {
        personSquareButton.setImage(
            UIImage(systemName: K.SystemImageName.personSquareFill),
            for: .normal
        )
        
        gridButton.setImage(
            UIImage(systemName: K.SystemImageName.gridSplit),
            for: .normal
        )
    }
    
}














