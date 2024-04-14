//
//  FeedVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit
import FirebaseAuth

private let feedCellIdentifier = K
    .CellId
    .feedCellId

// MARK: - FeedVC

final class FeedVC: FeedStyleVC {
    
    // MARK: - Properties
    
    private lazy var posts: [Post] = []
    
    fileprivate var isLoadingPost: Bool = false
    
    // MARK: - UIElement
    
    private lazy var logOutButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            title: K.ButtonTitle.logOut,
            style: .done,
            target: self,
            action: #selector(handleLogOut)
        )
        
        return barButton
    }()
    
    private lazy var refresher = UIRefreshControl()
    
}

// MARK: - Life Cycle

extension FeedVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.delegate = self
        
        configUI()
        loadRecentPosts()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadRecentPosts),
            name: Notification.Name(K.NotificationName.updatePost),
            object: nil
        )
        
    }
    
}

// MARK: - Set

extension FeedVC {
    
    private func configUI() {
        self.title = K.appName
        navigationItem.rightBarButtonItems = [logOutButton]
        
        collectionView.refreshControl = refresher
        
        refresher.addTarget(
            self,
            action: #selector(loadRecentPosts),
            for: .valueChanged
        )
    }
    
}

// MARK: - @objc Actions

extension FeedVC {
    
    @objc private func loadRecentPosts() {
        isLoadingPost = true
        
        PostService.getRecentPosts(limit: 10) { [unowned self] newPosts in
            
            if !(newPosts.isEmpty) {
                posts = newPosts
            } else {
                posts.removeAll()
                collectionView.reloadData()
            }
            
            isLoadingPost = false
            
            if refresher.isRefreshing {
                // 讓動畫效果更佳，在結束更新之前延遲 0.5秒
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
                    refresher.endRefreshing()
                }
            }
            
            if !(posts.isEmpty) { checkIfUserLikedPosts() }
        }
    }
    
    @objc private func handleLogOut() {
        do {
            try Auth.auth().signOut()
            
            let loginVC = LoginVC()
            
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
            
        } catch {
            fatalError("登出失敗： \(error.localizedDescription)")
        }
    }
    
}

// MARK: - Service

extension FeedVC {
    
    private func checkIfUserLikedPosts() {
        let group = DispatchGroup()
        
        // 遍歷所有貼文並檢查用戶是否已經按讚
        for post in posts {
            group.enter()
            
            PostService.checkIfUserLikedPost(post: post) { [weak self] didLike in
                guard let self = self else { return }
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId } ) {
                    self.posts[index].didLike = didLike
                }
                group.leave()
            }
        }
        
        // 當所有檢查完成後更新 UI
        group.notify(queue: .main) {
            self.collectionView.reloadData()
            self.collectionView.setContentOffset(.zero, animated: true)
        }
    }
    
    private func checkIfUserLikedOldPosts(_ prevPosts: [Post]) {
        let group = DispatchGroup()
        
        var oldPosts: [Post] = prevPosts
        
        for post in oldPosts {
            group.enter()
            PostService.checkIfUserLikedPost(post: post) { didLike in
                if let i = oldPosts.firstIndex(where: { $0.postId == post.postId } ) {
                    oldPosts[i].didLike = didLike
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [unowned self] in
            var indexPaths: [IndexPath] = []
            
            for post in oldPosts {
                posts.append(post)
                
                let indexPath = IndexPath(item: posts.count - 1, section: 0)
                indexPaths.append(indexPath)
            }
            
            insertOldPost(indexPaths: indexPaths)
        }
    }
    
    private func loadOldPosts(timeStamp: Int) {
        isLoadingPost = true
        
        PostService.getOldPosts(start: timeStamp, limit: 10) { [unowned self] prevPosts in
            checkIfUserLikedOldPosts(prevPosts)
        }
    }
    
    private func fetchPostLikes(postID: String, indexPath: IndexPath) {
        PostService.fetchPost(postId: postID) { [unowned self] post in
            guard let likes = post?.likes else { return }
            
            DispatchQueue.main.async { [unowned self] in
                posts[indexPath.item].likes = likes
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func fetchPostCaption(postID: String) {
        PostService.fetchPost(postId: postID) { [unowned self] post in
            guard let post = post else { return }
            guard let index = self.posts.firstIndex(where: { $0.postId == post.postId } ) else { return }
            let indexPath = IndexPath(item: index, section: 0)
            
            PostService.checkIfUserLikedPost(post: post) { didLike in
                DispatchQueue.main.async { [unowned self] in
                    posts[index].caption = post.caption
                    posts[index].didLike = didLike
                    
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
    }
    
    private func serviceDeletePost(postId: String) {
        PostService.deletePost(postId: postId) { [weak self] error, success in
            if error != nil || !success {
                self?.showLoader(false)
                self?.loadRecentPosts()
            }
            self?.deleteCommentsInPost(postID: postId)
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
            
            showLoader(false)
            loadRecentPosts()
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension FeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! FeedCell
        cell.postSettingDelegate = self
        
        let post = posts[indexPath.item]
        
        cell.vm = PostVM(post: post, indexPath: indexPath)
        
        cell.captionLabel.numberOfLines = posts[indexPath.item].isExpanded ? 0 : 2
        
        cell.tapCaptionAction = { [unowned self] in
            // 如果已經展開，將不執行後續行為
            guard !posts[indexPath.item].isExpanded else { return }
            
            posts[indexPath.item].isExpanded.toggle()
            
            PostService.checkIfUserLikedPost(post: post) { [unowned self] didLike in
                posts[indexPath.item].didLike = didLike
                fetchPostLikes(postID: post.postId, indexPath: indexPath)
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension FeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        // 在使用者滑到最後兩列時，觸發加載舊貼文
        guard !isLoadingPost, (posts.count - indexPath.row) == 2 else { return }
        guard let lastPostTimestamp = posts.last?.timestamp else { return }
        
        loadOldPosts(timeStamp: lastPostTimestamp)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedVC {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let superSize = super.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
        
        let width = superSize.width
        var height = superSize.height
        
        if posts[indexPath.item].isExpanded {
            height += posts[indexPath.item].captionHeight
        }
        
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - FeedStyleVCDelegate

extension FeedVC: FeedStyleVCDelegate {
    
    func checkPostLike(post: Post) {
        PostService.checkIfUserLikedPost(post: post) { [unowned self] didLike in
            if let index = posts.firstIndex(where: { $0.postId == post.postId } ) {
                posts[index].didLike = didLike
                
                PostService.fetchPost(postId: post.postId) { [unowned self] post in
                    guard let likes = post?.likes else { return }
                    posts[index].likes = likes
                }
            }
        }
    }
    
}

// MARK: - FeedCellDelegate

extension FeedVC: FeedCellPostSettingDelegate {
    
    func presentPostSettingVC(ownerUid: String, postId: String, indexPath: IndexPath) {
        let postSettingVC = PostSettingVC(
            performVC: K.VCName.feed,
            ownerUid: ownerUid,
            postId: postId
        )
        
        postSettingVC.delegate = self
        
        let sheetVC = SheetFactory.makeSheetVC(vc: postSettingVC)
        self.present(sheetVC, animated: true)
    }
    
}

// MARK: - PostSettingDelegate

extension FeedVC: PostSettingDelegate {
    
    func updateEditedPost(postId: String) {
        fetchPostCaption(postID: postId)
    }
    
    func deletePost(postId: String) {
        showLoader(true)
        serviceDeletePost(postId: postId)
    }
    
    // 不要在這個函式內撰寫任何內容
    func deleteProfilePost(postId: String) {}
    
}

// MARK: - Helper Methods

extension FeedVC {
    
    private func insertOldPost(indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
            isLoadingPost = false
        }
    }
    
}

