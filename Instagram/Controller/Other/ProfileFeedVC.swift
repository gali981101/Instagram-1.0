//
//  ProfileFeedVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/28.
//

import UIKit

private let feedCellIdentifier = K
    .CellId
    .feedCellId

// MARK: - ProfileFeedVC

final class ProfileFeedVC: FeedStyleVC {
    
    // MARK: - Properties
    
    lazy var userPosts: [Post] = []
    
    private var startIndexPath: IndexPath
    private var isSetIndexPath: Bool = true
    
    fileprivate var isLoadingPost: Bool = false
    
    // MARK: - init
    
    init(startIndexPath: IndexPath, layout: UICollectionViewFlowLayout) {
        self.startIndexPath = startIndexPath
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension ProfileFeedVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSetIndexPath { configUI() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isSetIndexPath = false
    }
    
}

// MARK: - Set

extension ProfileFeedVC {
    
    private func configUI() {
        view.backgroundColor = .systemBackground
        
        let yOffSet = CGFloat(startIndexPath.item) * collectionView.bounds.height
        collectionView.setContentOffset(CGPoint(x: 0, y: yOffSet), animated: false)
    }
    
}



// MARK: - Service

extension ProfileFeedVC {
    
    private func loadUserOldPosts(timeStamp: Int) {
    }
    
    private func checkIfUserLikedPosts() {
        let group = DispatchGroup()
        
        // 遍歷所有貼文並檢查用戶是否已經按讚
        for post in userPosts {
            group.enter()
            
            PostService.checkIfUserLikedPost(post: post) { [weak self] didLike in
                guard let self = self else { return }
                if let index = self.userPosts.firstIndex(where: { $0.postId == post.postId } ) {
                    self.userPosts[index].didLike = didLike
                }
                group.leave()
            }
        }
        
        // 當所有檢查完成後更新 UI
        group.notify(queue: .main) { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func fetchPostLikes(postID: String, indexPath: IndexPath) {
        PostService.fetchPost(postId: postID) { [unowned self] post in
            guard let likes = post?.likes else { return }
            
            DispatchQueue.main.async { [unowned self] in
                userPosts[indexPath.item].likes = likes
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func fetchPostCaption(postID: String) {
        PostService.fetchPost(postId: postID) { [unowned self] post in
            guard let post = post else { return }
            guard let index = self.userPosts.firstIndex(where: { $0.postId == post.postId } ) else { return }
            let indexPath = IndexPath(item: index, section: 0)
            
            PostService.checkIfUserLikedPost(post: post) { didLike in
                DispatchQueue.main.async { [unowned self] in
                    userPosts[index].caption = post.caption
                    userPosts[index].didLike = didLike
                    
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    private func serviceDeletePost(postId: String) {
        PostService.deletePost(postId: postId) { [unowned self] error, success in
            if error != nil || !success {
                for i in 0...userPosts.count - 1 {
                    if userPosts[i].postId == postId {
                        userPosts.remove(at: i)
                        break
                    }
                }
                
                showLoader(false)
                collectionView.reloadData()
                return
            }
            
            deleteCommentsInPost(postID: postId)
        }
    }
    
    private func deleteCommentsInPost(postID: String) {
        CommentService.deleteComments(forPost: postID) { [unowned self] in
            deleteLikesInPost(postID: postID)
        }
    }
    
    private func deleteLikesInPost(postID: String) {
        PostService.deletePostLikes(postId: postID) { [unowned self] error in
            if let error = error { fatalError(error.localizedDescription) }
            removePostFromUserPosts(deletePostId: postID)
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension ProfileFeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = userPosts[indexPath.item]
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! FeedCell
        
        cell.vm = PostVM(post: post, indexPath: indexPath)
        cell.postSettingDelegate = self
        
        cell.captionLabel.numberOfLines = userPosts[indexPath.item].isExpanded ? 0 : 2
        
        cell.tapCaptionAction = { [unowned self] in
            guard !userPosts[indexPath.item].isExpanded else { return }
            
            userPosts[indexPath.item].isExpanded.toggle()
            
            PostService.checkIfUserLikedPost(post: post) { [unowned self] didLike in
                userPosts[indexPath.item].didLike = didLike
                fetchPostLikes(postID: post.postId, indexPath: indexPath)
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ProfileFeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 在使用者滑到最後兩列時，觸發加載用戶的舊貼文
        guard !isLoadingPost, (userPosts.count - indexPath.row) == 2 else { return }
        guard let lastPostTimestamp = userPosts.last?.timestamp else { return }
        
        loadUserOldPosts(timeStamp: lastPostTimestamp)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileFeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let superSize = super.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
        
        let width = superSize.width
        var height = superSize.height
        
        if userPosts[indexPath.item].isExpanded {
            height += userPosts[indexPath.item].captionHeight
        }
        
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - FeedStyleVCDelegate

extension ProfileFeedVC: FeedStyleVCDelegate {
    
    func checkPostLike(post: Post) {
        PostService.checkIfUserLikedPost(post: post) { [unowned self] didLike in
            if let index = userPosts.firstIndex(where: { $0.postId == post.postId } ) {
                userPosts[index].didLike = didLike
                
                PostService.fetchPost(postId: post.postId) { [unowned self] post in
                    guard let likes = post?.likes else { return }
                    userPosts[index].likes = likes
                }
            }
        }
    }
    
}

// MARK: - FeedCellDelegate

extension ProfileFeedVC: FeedCellPostSettingDelegate {
    
    func presentPostSettingVC(ownerUid: String, postId: String, indexPath: IndexPath) {
        let postSettingVC = PostSettingVC(
            performVC: K.VCName.profile,
            ownerUid: ownerUid,
            postId: postId
        )
        
        postSettingVC.delegate = self
        
        let sheetVC = SheetFactory.makeSheetVC(vc: postSettingVC)
        self.present(sheetVC, animated: true)
    }
    
}

// MARK: - PostSettingDelegate

extension ProfileFeedVC: PostSettingDelegate {
    
    func updateEditedPost(postId: String) {
        fetchPostCaption(postID: postId)
    }
    
    func deleteProfilePost(postId: String) {
        showLoader(true)
        serviceDeletePost(postId: postId)
    }
    
    // 不要在這個函式內撰寫任何內容
    func deletePost(postId: String) {}
    
}

// MARK: - Helper Methods

extension ProfileFeedVC {
    
    private func insertUserOldPost(indexPaths: [IndexPath]) {}
    
    private func removePostFromUserPosts(deletePostId: String) {
        for i in 0...userPosts.count - 1 {
            if userPosts[i].postId == deletePostId {
                userPosts.remove(at: i)
                break
            }
        }
        
        showLoader(false)
        
        checkIfUserLikedPosts()
    }
    
}













































