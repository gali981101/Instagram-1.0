//
//  ProfileVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit

private let profileCellId: String = K.CellId.profileCellId

// MARK: - ProfileVC

final class ProfileVC: UIViewController {
    
    // MARK: - Properties
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            header.vm = ProfileHeaderVM(user: user)
            collectionView.reloadData()
        }
    }
    
    // MARK: - UIElemaent
    
    private lazy var header = ProfileHeader()
    
    private lazy var collectionView: UICollectionView = {
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
            ProfileCell.self,
            forCellWithReuseIdentifier: profileCellId
        )
        
        cv.backgroundColor = .systemBackground
        cv.isPagingEnabled = true
        
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    // MARK: - init
    
    init(user: User? = nil) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
        if let user = user {
            checkUserIsFollowed(user: user)
            
            header.vm = ProfileHeaderVM(user: user)
            collectionView.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension ProfileVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        header.delegate = self
        
        style()
        layout()
        
        if user == nil { fetchUser() }
        
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchUser),
            name: Notification.Name(K.NotificationName.updateUser),
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let user = user else { return }
        fetchUserStats(user: user)
    }
    
}

// MARK: - Set

extension ProfileVC {
    
    private func style() {
        view.addSubview(header)
        view.addSubview(collectionView)
    }
    
    private func layout() {
        header.setDimensions(height: 240, width: view.frame.width)
        
        header.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor
        )
        
        collectionView.anchor(
            top: header.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 2
        )
    }
    
}

// MARK: - Service

extension ProfileVC {
    
    private func checkUserIsFollowed(user: User) {
        UserService.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user?.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserStats(user: User) {
        UserService.fetchUserStats(uid: user.uid) { [weak self] stats in
            self?.user?.stats = stats
            self?.collectionView.reloadData()
        }
    }
    
}

// MARK: - @objc Actions

extension ProfileVC {
    
    @objc private func fetchUser() {
        UserService.fetchUser { [weak self] user in
            self?.user = user
            
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.title = user.username
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension ProfileVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: profileCellId,
            for: indexPath) as! ProfileCell
        
        cell.delegate = self
        cell.user = user
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ProfileVC: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        header.selectItem(at: Int(index))
    }
    
}

// MARK: - ProfileHeaderDelegate

extension ProfileVC: ProfileHeaderDelegate {
    
    func showFollowerPage(uid: String, isFollowerPage: Bool) {
        let followerVC = FollowerVC(userUid: uid, isFollowers: isFollowerPage)
        navigationController?.pushViewController(followerVC, animated: true)
    }
    
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        
        if user.isCurrentUser {
            print("DEBUG: Show edit profile here..")
        } else if user.isFollowed {
            UserService.unfollow(uid: user.uid) { [unowned self] error in
                if error != nil { return }
                self.user?.isFollowed = false
                
                collectionView.reloadData()
            }
        } else {
            UserService.follow(uid: user.uid) { [unowned self] error in
                if error != nil { return }
                self.user?.isFollowed = true
                
                collectionView.reloadData()
                
                UserService.fetchUser { [unowned self] currentUser in
                    uploadFollowNotify(user: user, currentUser: currentUser)
                }
            }
        }
        
    }
    
    
    func didSelectItemAt(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        
        collectionView.scrollToItem(
            at: indexPath,
            at: [],
            animated: true
        )
    }
    
}

// MARK: - ProfileCellDelegate

extension ProfileVC: ProfileCellDelegate {
    
    func pushToFeedVC(posts: [Post], indexPath: IndexPath) {
        
        let layOut = UICollectionViewFlowLayout()
        
        let profileFeedVC = ProfileFeedVC(startIndexPath: indexPath, layout: layOut)
        profileFeedVC.userPosts = posts
        
        navigationController?.pushViewController(profileFeedVC, animated: true)
    }
    
}

// MARK: - Helper Methods

extension ProfileVC {
    
    private func uploadFollowNotify(user: User, currentUser: User) {
        NotifyService.uploadNotification(toUid: user.uid, fromUser: currentUser, type: .follow)
    }
    
}
