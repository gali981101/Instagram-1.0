//
//  GridCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/15.
//

import UIKit
import SDWebImage

private let gridCellIdentifier = K.CellId.gridCellId

// MARK: - ProfileCellDelegate

protocol ProfileCellDelegate: AnyObject {
    func pushToFeedVC(posts: [Post], indexPath: IndexPath)
}

// MARK: - ProfileCell

final class ProfileCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    weak var delegate: ProfileCellDelegate?
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            fetchPosts(user: user)
        }
    }
    
    private lazy var posts: [Post] = []
    
    // MARK: - UIElement
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(
            GridCell.self,
            forCellWithReuseIdentifier: gridCellIdentifier
        )
        
        cv.backgroundColor = .systemBackground
        
        return cv
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set

extension ProfileCell {
    
    private func style() {
        addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = false
    }
    
    private func layout() {
        collectionView.anchor(
            top: topAnchor,
            left: leftAnchor, bottom: bottomAnchor,
            right: rightAnchor
        )
    }
    
}

// MARK: - Service

extension ProfileCell {
    
    private func fetchPosts(user: User) {
        PostService.fetchUserPosts(forUser: user.uid, limit: 9) { [weak self] posts in
            self?.posts = posts
            self?.checkIfUserLikedPosts()
        }
    }
    
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
        group.notify(queue: .main) { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
}

// MARK: - @objc Actions

extension ProfileCell {
}

// MARK: - UICollectionViewDataSource

extension ProfileCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: gridCellIdentifier,
            for: indexPath
        ) as! GridCell
        
        cell.vm = PostVM(post: self.posts[indexPath.item], indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ProfileCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pushToFeedVC(posts: self.posts, indexPath: indexPath)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
}


