//
//  FeedCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit
import SDWebImage

private let gridCellIdentifier = K.CellId.gridCellId

// MARK: - FeedCellDelegate

protocol FeedCellDelegate: AnyObject {
    func cell(_ cell: FeedCell, didLike post: Post)
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post)
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String)
    func cell(_ cell: FeedCell, wantsToShowLikesFor postId: String)
}

// MARK: - FeedCellPostSettingDelegate

protocol FeedCellPostSettingDelegate: AnyObject {
    func presentPostSettingVC(ownerUid: String, postId: String, indexPath: IndexPath)
}

// MARK: - FeedCell

final class FeedCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: FeedCellDelegate?
    weak var postSettingDelegate: FeedCellPostSettingDelegate?
    
    var tapCaptionAction: (() -> Void)?
    
    var vm: PostVM? {
        didSet { config() }
    }
    
    private var postId: String?
    private var ownerUid: String?
    private var indexPath: IndexPath?
    
    private lazy var imageUrls: [URL] = []
    
    // MARK: - UIElements
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        imageView.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(showUserProfile)
        )
        
        imageView.addGestureRecognizer(tap)
        
        return imageView
    }()
    
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.isUserInteractionEnabled = true
    
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLikesLabel)
        )
        
        label.addGestureRecognizer(tap)
        
        return label
    }()
    
    lazy var captionLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var postTimeLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        
        return label
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitleColor(.label, for: .normal)
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        
        button.addTarget(
            self,
            action: #selector(showUserProfile),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.tintColor = .label
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        
        button.addTarget(
            self,
            action: #selector(didTapMoreButton),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(
            GridCell.self,
            forCellWithReuseIdentifier: gridCellIdentifier
        )
        
        cv.backgroundColor = .systemBackground
        
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(systemName: K.SystemImageName.heart),
            for: .normal
        )
        
        button.tintColor = .label
        
        button.addTarget(
            self,
            action: #selector(didTapHeartButton),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        
        control.addTarget(
            self,
            action: #selector(changePage),
            for: .valueChanged
        )
        
        control.pageIndicatorTintColor = .gray.withAlphaComponent(0.5)
        control.currentPageIndicatorTintColor = ThemeColor.red3
        
        control.currentPage = 0
        
        return control
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(systemName: K.SystemImageName.message),
            for: .normal
        )
        
        button.addTarget(
            self,
            action: #selector(didTapCommentButton),
            for: .touchUpInside
        )
        
        button.tintColor = .label
        
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(systemName: K.SystemImageName.paperplane),
            for: .normal
        )
        
        button.tintColor = .label
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            likeButton,
            commentButton,
            shareButton]
        )
        
        view.axis = .horizontal
        view.distribution = .fillEqually
        
        return view
    }()
    
    private lazy var bookMarkButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(systemName: K.SystemImageName.bookmark),
            for: .normal
        )
        
        button.tintColor = .label
        
        return button
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set

extension FeedCell {
    
    private func style() {
        backgroundColor = .systemBackground
        
        addSubview(profileImageView)
        addSubview(usernameButton)
        addSubview(moreButton)
        addSubview(imageCollectionView)
        addSubview(pageControl)
        addSubview(stackView)
        addSubview(bookMarkButton)
        addSubview(likesLabel)
        addSubview(captionLabel)
        addSubview(postTimeLabel)
        
        profileImageView.layer.cornerRadius = 40 / 2
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapCaptionLabel)
        )
        
        captionLabel.addGestureRecognizer(tap)
    }
    
    private func layout() {
        profileImageView.setDimensions(height: 40, width: 40)
        
        profileImageView.anchor(
            top: topAnchor,
            left: leftAnchor,
            paddingTop: 12,
            paddingLeft: 12
        )
        
        usernameButton.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
        
        moreButton.centerY(inView: usernameButton)
        
        moreButton.anchor(
            right: rightAnchor,
            paddingRight: 12
        )
        
        imageCollectionView.anchor(
            top: profileImageView.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 8
        )
        
        imageCollectionView.heightAnchor.constraint(
            equalTo: widthAnchor,
            multiplier: 1
        ).isActive = true
        
        stackView.anchor(
            top: imageCollectionView.bottomAnchor,
            left: leftAnchor,
            paddingLeft: 8,
            width: 120,
            height: 50
        )
        
        pageControl.centerY(inView: stackView)
        pageControl.centerX(inView: self)
        
        pageControl.setWidth(135)
        
        for dot in pageControl.subviews {
            dot.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }
        
        bookMarkButton.centerY(inView: stackView)
        
        bookMarkButton.anchor(
            right: rightAnchor,
            paddingRight: 20
        )
        
        likesLabel.anchor(
            top: likeButton.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: -4,
            paddingLeft: 16,
            paddingRight: 16
        )
        
        captionLabel.anchor(
            top: likesLabel.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingRight: 16
        )
        
        postTimeLabel.anchor(
            top: captionLabel.bottomAnchor,
            left: leftAnchor,
            right: rightAnchor,
            paddingTop: 8,
            paddingLeft: 16,
            paddingRight: 16
        )
    }
    
}

// MARK: - @objc Actions

extension FeedCell {
    
    @objc private func showUserProfile() {
        guard let vm = vm else { return }
        delegate?.cell(self, wantsToShowProfileFor: vm.ownerUid)
    }
    
    @objc private func didTapMoreButton() {
        guard let ownerUid = ownerUid else { return }
        guard let postId = postId else { return }
        guard let indexPath = indexPath else { return }
        
        postSettingDelegate?.presentPostSettingVC(ownerUid: ownerUid, postId: postId, indexPath: indexPath)
    }
    
    @objc private func didTapCaptionLabel() {
        tapCaptionAction?()
    }
    
    @objc private func didTapHeartButton() {
        guard let vm = vm else { return }
        delegate?.cell(self, didLike: vm.post)
    }
    
    @objc private func didTapLikesLabel() {
        guard let postId = vm?.postId else { return }
        delegate?.cell(self, wantsToShowLikesFor: postId)
    }
    
    @objc private func didTapCommentButton() {
        guard let vm = vm else { return }
        delegate?.cell(self, wantsToShowCommentsFor: vm.post)
    }
    
    @objc private func changePage(sender: AnyObject) {
        let x = CGFloat(pageControl.currentPage) * imageCollectionView.frame.size.width
        imageCollectionView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource

extension FeedCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: gridCellIdentifier,
            for: indexPath) as! GridCell
        
        cell.postImageView.sd_setImage(with: imageUrls[indexPath.item])
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension FeedCell: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.frame.width
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
}

// MARK: - Helper Methods

extension FeedCell {
    
    private func config() {
        guard let vm = vm else { return }
        guard let urls = vm.imageUrls else { return }
        
        usernameButton.setTitle(
            vm.ownerUsername,
            for: .normal
        )
        
        imageUrls = urls
        
        captionLabel.text = vm.caption
        postTimeLabel.text = vm.timestampString
        likesLabel.text = vm.likesLabelText
        
        likeButton.tintColor = vm.likeButtonTintColor
        likeButton.setImage(vm.likeButtonImage, for: .normal)
        
        ownerUid = vm.ownerUid
        postId = vm.postId
        
        indexPath = vm.indexPath
        
        pageControl.numberOfPages = imageUrls.count == 1 ? 0 : imageUrls.count
        
        profileImageView.sd_setImage(with: vm.ownerImageUrl)
        
        imageCollectionView.reloadData()
    }
    
}


