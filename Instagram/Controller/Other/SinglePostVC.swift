//
//  SinglePostVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/6.
//

import UIKit

private let feedCellIdentifier = K
    .CellId
    .feedCellId

// MARK: - SinglePostVC

final class SinglePostVC: FeedStyleVC {
    
    // MARK: - Properties
    
    private var singlePost: Post?
    
    private var postId: String
    
    // MARK: - UIElement
    
    private lazy var refresher = UIRefreshControl()
    
    // MARK: - init
    
    init(postId: String, layout: UICollectionViewLayout) {
        self.postId = postId
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension SinglePostVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        loadPost()
    }
    
}

// MARK: - Set

extension SinglePostVC {
    
    private func configUI() {
        self.title = K.Title.post
        
        collectionView.refreshControl = refresher
        
        refresher.addTarget(self, action: #selector(loadPost), for: .valueChanged)
    }
    
}

// MARK: - @objc Actions

extension SinglePostVC {
    
    @objc private func loadPost() {
        PostService.fetchPost(postId: postId) { [unowned self] post in
            
            if post != nil {
                singlePost = post
            }
            
            if refresher.isRefreshing {
                // 讓動畫效果更佳，在結束更新之前延遲 0.5秒
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
                    refresher.endRefreshing()
                }
            }
            
            checkIfUserLikedPost()
        }
    }
    
}

// MARK: - Service

extension SinglePostVC {
    
    private func checkIfUserLikedPost() {
        if let post = singlePost {
            PostService.checkIfUserLikedPost(post: post) { [weak self] didLike in
                self?.singlePost!.didLike = didLike
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func fetchPostLikes(postId: String) {
        PostService.fetchPost(postId: postId) { [unowned self] post in
            guard let likes = post?.likes else { return }
            singlePost?.likes = likes
            
            collectionView.reloadData()
        }
    }
    
    private func serviceDeletePost(postId: String) {
        PostService.deletePost(postId: postId) { [unowned self] error, success in
            if error != nil { fatalError(error!.localizedDescription) }
            if !success {
                singlePost = nil
                collectionView.reloadData()
            }
            
            deleteCommentsInPost(postId: postId)
        }
    }
    
    private func deleteCommentsInPost(postId: String) {
        CommentService.deleteComments(forPost: postId) { [unowned self] in
            deleteLikesInPost(postId: postId)
        }
    }
    
    private func deleteLikesInPost(postId: String) {
        PostService.deletePostLikes(postId: postId) { [unowned self] error in
            if let error = error { fatalError(error.localizedDescription) }
            showLoader(false)
            singlePost = nil
            collectionView.reloadData()
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension SinglePostVC {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return singlePost == nil ? 0 : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! FeedCell
        cell.postSettingDelegate = self
        
        if let post = singlePost {
            cell.vm = PostVM(post: post, indexPath: indexPath)
            
            cell.captionLabel.numberOfLines = post.isExpanded ? 0 : 2
            
            cell.tapCaptionAction = { [unowned self] in
                guard !post.isExpanded else { return }
                singlePost!.isExpanded.toggle()
                
                PostService.checkIfUserLikedPost(post: post) { [unowned self] didLike in
                    singlePost?.didLike = didLike
                    fetchPostLikes(postId: post.postId)
                }
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SinglePostVC {
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let superSize = super.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
        
        let width = superSize.width
        var height = superSize.height
        
        if let post = singlePost, post.isExpanded {
            height += post.captionHeight
        }
        
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - FeedCellDelegate

extension SinglePostVC: FeedCellPostSettingDelegate {
    
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

extension SinglePostVC: PostSettingDelegate {
    
    func updateEditedPost(postId: String) {
        loadPost()
    }

    func deletePost(postId: String) {
        showLoader(true)
        serviceDeletePost(postId: postId)
    }
    
    // 不要在這個函式內撰寫任何內容
    func deleteProfilePost(postId: String) {}
    
}

