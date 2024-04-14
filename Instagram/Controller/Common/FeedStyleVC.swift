//
//  FeedStyleVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/27.
//

import UIKit

private let feedCellIdentifier = K
    .CellId
    .feedCellId

// MARK: - FeedStyleVCDelegate

protocol FeedStyleVCDelegate: AnyObject {
    func checkPostLike(post: Post)
}

// MARK: - FeedStyleVC

class FeedStyleVC: UICollectionViewController {
    
    // MARK: - Properties
    
    weak var delegate: FeedStyleVCDelegate?
    
    fileprivate var arrayIndexPaths: [IndexPath] = []
    
    // MARK: - UIElement
}

// MARK: - Life Cycle

extension FeedStyleVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
}

// MARK: - Set

extension FeedStyleVC {
    
    private func configUI() {
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.isTranslucent = false
        
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(
            FeedCell.self,
            forCellWithReuseIdentifier: feedCellIdentifier
        )
    }
    
}

// MARK: - UICollectionViewDataSource

extension FeedStyleVC {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: feedCellIdentifier,
            for: indexPath
        ) as! FeedCell
        
        cell.delegate = self
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension FeedStyleVC {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if !(arrayIndexPaths.contains(indexPath)) {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 200, 0)
            
            cell.alpha = 0
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 1.0, animations: {
                cell.alpha = 1
                cell.layer.transform = CATransform3DIdentity
            })
            
            arrayIndexPaths.append(indexPath)
        }
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedStyleVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        
        height += 100
        height += 60
        
        return CGSize(width: width, height: height)
    }
    
}

// MARK: - FeedCellDelegate

extension FeedStyleVC: FeedCellDelegate {
    
    func cell(_ cell: FeedCell, didLike post: Post) {
        cell.vm?.post.didLike.toggle()
        
        if post.didLike {
            PostService.unLikePost(post: post) { [weak self] error in
                if let error = error { fatalError(error.localizedDescription) }
                
                cell.likeButton.setImage(UIImage(systemName: K.SystemImageName.heart), for: .normal)
                cell.likeButton.tintColor = .label
                cell.vm?.post.likes = post.likes - 1
                
                self?.delegate?.checkPostLike(post: post)
            }
        } else {
            PostService.likePost(post: post) { error in
                if let error = error { fatalError(error.localizedDescription) }
                
                cell.likeButton.animateHeart()
                cell.vm?.post.likes = post.likes + 1
                
                self.delegate?.checkPostLike(post: post)
                
                UserService.fetchUser { [unowned self] user in
                    uploadNotification(post: post, user: user)
                }
            }
        }
    }
    
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let commentVC = CommentVC(post: post)
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(with: uid) { [weak self] user in
            let profileVC = ProfileVC(user: user)
            self?.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    func cell(_ cell: FeedCell, wantsToShowLikesFor postId: String) {
        let userListVC = PostLikesVC(postId: postId)
        self.navigationController?.pushViewController(userListVC, animated: true)
    }
    
}

// MARK: - Helper Methods

extension FeedStyleVC {
    
    private func uploadNotification(post: Post, user: User) {
        NotifyService.uploadNotification(toUid: post.ownerUid, fromUser: user, type: .like, post: post)
    }
    
}













