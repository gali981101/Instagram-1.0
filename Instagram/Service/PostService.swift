//
//  PostService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/22.
//

import UIKit
import Firebase

// MARK: - CompletionBlock

typealias imagesCompletionBlock = () -> Void
typealias deleteImagesCompletionBlock = (Bool) -> Void
typealias fetchPostsCompletionBlock = ([Post]) -> Void
typealias fetchPostCompletionBlock = (Post?) -> Void
typealias deletePostCompletionBlock = (Error?, Bool) -> Void

// MARK: - PostService

struct PostService {
    
    private static var imagesUrl: [String] = []
    
    // MARK: - init
    
    private init() {}
}

// MARK: - Upload Post

extension PostService {
    
    static func uploadPost(caption: String, images: [UIImage], owner: User, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        startUploading(images: images) {
            let data = [
                K.Post.caption: caption,
                K.Post.timestamp: Int(Date().timeIntervalSince1970 * 1000),
                K.Post.likes: 0,
                K.Post.imagesURL: imagesUrl,
                K.Post.ownerUid: uid,
                K.Post.ownerImageUrl: owner.profileImageUrl,
                K.Post.ownerUsername: owner.username
            ] as [String: Any]
            
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
    }
    
}

// MARK: - Upload Multiple Images

extension PostService {
    
    private static func startUploading(images: [UIImage], completion: @escaping imagesCompletionBlock) {
        imagesUrl = []
        
        if images.count == 0 {
            completion()
            return
        }
        
        uploadImages(images: images, forIndex: 0, completion: completion)
    }
    
    private static func uploadImages(images: [UIImage], forIndex i: Int, completion: @escaping imagesCompletionBlock) {
        if i < images.count {
            ImageUploader.uploadImage(image: images[i], isPost: true) { url in
                imagesUrl.append(url)
                uploadImages(images: images, forIndex: i + 1, completion: completion)
            }
            return
        }
        
        completion()
    }
    
}

// MARK: - Get Recent Posts

extension PostService {
    
    static func getRecentPosts(start timestamp: Int? = nil, limit: Int, completion: @escaping fetchPostsCompletionBlock) {
        var postQuery = COLLECTION_POSTS
            .order(by: K.Post.timestamp, descending: true)
        
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            // 如果有指定時戳，將會以比給定值來的新的時戳來取得貼文
            postQuery = postQuery
                .whereField(K.Post.timestamp, isGreaterThan: latestPostTimestamp)
                .limit(to: limit)
        } else {
            // 否則的話，將會取得最近的貼文
            postQuery = postQuery.limit(to: limit)
        }
        
        loadRecentPostData(postQuery: postQuery, completion: completion)
    }
    
}

// MARK: - Get Old Posts

extension PostService {
    
    static func getOldPosts(start timestamp: Int, limit: Int, completion: @escaping fetchPostsCompletionBlock) {
        let postQuery = COLLECTION_POSTS
            .order(by: K.Post.timestamp, descending: true)
            .whereField(K.Post.timestamp, isLessThan: timestamp)
            .limit(to: limit)
        
        postQuery.getDocuments { snapshot, error in
            if error != nil {
                completion([])
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            var oldPosts: [Post] = []
            
            for document in snapshot.documents {
                let postData = document.data()
                let postID = document.documentID
                
                let post = Post(postId: postID, dict: postData)
                oldPosts.append(post)
            }
            
            oldPosts.sort(by: { $0.timestamp > $1.timestamp } )
            completion(oldPosts)
        }
    }
    
}

// MARK: - Fetch Post

extension PostService {
    
    static func fetchPost(postId: String, completion: @escaping fetchPostCompletionBlock) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, error in
            if error != nil { fatalError() }
            
            guard let snapshot = snapshot else {
                completion(nil)
                return
            }
            
            guard let data = snapshot.data() else {
                completion(nil)
                return
            }
            
            let post = Post(postId: snapshot.documentID, dict: data)
            completion(post)
        }
    }
    
}

// MARK: - Fetch User Posts

extension PostService {
    
    static func fetchUserPosts(forUser uid: String, limit: Int, completion: @escaping fetchPostsCompletionBlock) {
        let query = COLLECTION_POSTS
            .whereField(K.Post.ownerUid, isEqualTo: uid)
            .limit(to: limit)
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            var posts = documents.map { Post(postId: $0.documentID, dict: $0.data()) }
            
            posts.sort(by: { $0.timestamp > $1.timestamp } )
            completion(posts)
        }
    }
    
}

// MARK: - Delete Post

extension PostService {
    
    static func deletePost(postId: String, completion: @escaping deletePostCompletionBlock) {
        startDeleting(postId: postId) { success in
            if success {
                COLLECTION_POSTS.document(postId).delete() { error in completion(error, success) }
            } else {
                completion(nil, success)
            }
        }
    }
    
}

// MARK: - Delete Multiple Images

extension PostService {
    
    private static func startDeleting(postId: String, completion: @escaping deleteImagesCompletionBlock) {
        fetchPost(postId: postId) { post in
            guard let urls = post?.imageUrls else {
                completion(false)
                return
            }
            deleteImages(urls: urls, forIndex: (urls.count - 1), completion: completion)
        }
    }
    
    private static func deleteImages(urls: [String], forIndex i: Int, completion: @escaping deleteImagesCompletionBlock) {
        if i >= 0 {
            ImageDeleter.deleteImage(url: urls[i]) {
                deleteImages(urls: urls, forIndex: i - 1, completion: completion)
            }
            return
        }
        
        completion(true)
    }
    
}

// MARK: - Like Post

extension PostService {
    
    static func likePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS
            .document(post.postId)
            .updateData([K.Post.likes: post.likes + 1])
        
        let postQuery = COLLECTION_POSTS
            .document(post.postId)
            .collection(K.Post.postLikes)
        
        let userQuery = COLLECTION_USERS
            .document(uid)
            .collection(K.UserProfile.userLikes)
        
        postQuery.document(uid).setData([:]) { error in
            if let error = error { fatalError(error.localizedDescription) }
            userQuery.document(post.postId).setData([:], completion: completion)
        }
    }
    
}

// MARK: - Unlike Post

extension PostService {
    
    static func unLikePost(post: Post, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS
            .document(post.postId)
            .updateData([K.Post.likes: post.likes - 1])
        
        let postQuery = COLLECTION_POSTS
            .document(post.postId)
            .collection(K.Post.postLikes)
        
        let userQuery = COLLECTION_USERS
            .document(uid)
            .collection(K.UserProfile.userLikes)
        
        postQuery.document(uid).delete { error in
            if let error = error { fatalError(error.localizedDescription) }
            userQuery.document(post.postId).delete(completion: completion)
        }
    }
    
}

// MARK: - Check User Liked Post

extension PostService {
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_USERS
            .document(uid)
            .collection(K.UserProfile.userLikes)
            .document(post.postId)
        
        query.getDocument { snapshot, error in
            if let error = error { fatalError(error.localizedDescription) }
            guard let didLike = snapshot?.exists else { return }
            
            completion(didLike)
        }
    }
    
}

// MARK: - Delete Post Likes

extension PostService {
    
    static func deletePostLikes(postId: String, completion: @escaping(FirestoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let postLikeQuery = COLLECTION_POSTS
            .document(postId)
            .collection(K.Post.postLikes)
        
        let userLikeQuery = COLLECTION_USERS
            .document(uid)
            .collection(K.UserProfile.userLikes)
        
        // 刪除 postLikeQuery 內的所有文檔
        postLikeQuery.getDocuments { (snapshot, error) in
            if let error = error { fatalError(error.localizedDescription) }
            guard let documents = snapshot?.documents else { fatalError() }
            
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            deleteUserLikeQuery(query: userLikeQuery, batch: batch, postId: postId, completion: completion)
        }
    }
    
}

// MARK: - Edit post

extension PostService {
    
    static func updatePostCaption(postId: String, text: String, completion: @escaping(Error?) -> Void) {
        let newCaption = [K.Post.caption: text]
        COLLECTION_POSTS.document(postId).updateData(newCaption, completion: completion)
    }
    
}

// MARK: - Helper Methods

extension PostService {
    
    private static func loadRecentPostData(postQuery: Query, completion: @escaping fetchPostsCompletionBlock) {
        
        postQuery.getDocuments { snapshot, error in
            if let error = error { fatalError(error.localizedDescription) }
            guard let snapshot = snapshot else { fatalError() }
            
            var newPosts: [Post] = []
            
            for document in snapshot.documents {
                let postInfo = document.data()
                let post = Post(postId: document.documentID, dict: postInfo)
                
                newPosts.append(post)
            }
            
            if newPosts.count > 0 {
                // 以降冪排序 (也就是第一則貼文為最新貼文)
                newPosts.sort(by: { $0.timestamp > $1.timestamp })
            }
            
            completion(newPosts)
        }
        
    }
    
    private static func deleteUserLikeQuery(
        query: CollectionReference,
        batch: WriteBatch,
        postId: String,
        completion: @escaping(FirestoreCompletion)) {
            batch.deleteDocument(query.document(postId))
            batch.commit(completion: completion)
        }
    
}




























