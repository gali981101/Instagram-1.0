//
//  CommentService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/30.
//

import Firebase

// MARK: - CompletionBlock

typealias fetchCommentsCompletionBlock = ([Comment]) -> Void
typealias deleteCommentCompletionBlock = (Error?) -> Void

// MARK: - CommentService

enum CommentService {
    
    // MARK: - Upload Comment
    
    static func uploadComment(
        comment: String,
        post: Post,
        user: User,
        completion: @escaping(FirestoreCompletion)) {
            
            let data: [String: Any] = [
                K.Comment.uid: user.uid,
                K.Comment.comment: comment,
                K.Comment.timestamp: Int(Date().timeIntervalSince1970 * 1000),
                K.Comment.username: user.username,
                K.Comment.profileImageUrl: user.profileImageUrl,
                K.Comment.likes: [String]()
            ]
            
            COLLECTION_POSTS.document(post.postId)
                .collection(K.Post.comments)
                .addDocument(data: data, completion: completion)
        }
    
}

// MARK: - Fetch Comments

extension CommentService {
    
    static func fetchComments(
        forPost post: Post,
        start timestamp: Int? = nil,
        limit: Int,
        completion: @escaping fetchCommentsCompletionBlock) {
            
            var commentsDict: [String: Comment] = [:] // 使用字典來儲存留言
            
            var query = COLLECTION_POSTS.document(post.postId).collection(K.Post.comments)
                .order(by: K.Comment.timestamp, descending: true)
            
            if let timestamp = timestamp, timestamp > 0 {
                query = query
                    .whereField(K.Comment.timestamp, isLessThan: timestamp)
                    .limit(to: limit)
            } else {
                query = query.limit(to: limit)
            }
            
            query.addSnapshotListener { snapshot, error in
                if let error = error { fatalError(error.localizedDescription) }
                
                snapshot?.documentChanges.forEach({ change in
                    let data = change.document.data()
                    let id = change.document.documentID
                    
                    if change.type == .added {
                        let comment = Comment(commentId: id, dict: data)
                        commentsDict[id] = comment // 將留言添加到字典中
                    } else if change.type == .removed {
                        commentsDict.removeValue(forKey: id) // 從字典中移除被刪除的留言
                    }
                })
                
                // 將字典中的留言轉換為數組並傳遞给 completion handler
                var comments = Array(commentsDict.values)
                comments.sort(by: { $0.timestamp > $1.timestamp } )
                
                completion(comments)
            }
        }
    
}

// MARK: - Delete Comment

extension CommentService {
    
    static func deleteComment(forPost post: Post, commentID: String, completion: @escaping deleteCommentCompletionBlock) {
        let query = COLLECTION_POSTS
            .document(post.postId)
            .collection(K.Post.comments)
        
        query.document(commentID).delete { error in
            completion(error)
        }
    }
    
}

// MARK: - Delete Comments

extension CommentService {
    
    static func deleteComments(forPost postID: String, completion: @escaping () -> Void) {
        let query = COLLECTION_POSTS
            .document(postID)
            .collection(K.Post.comments)
        
        // 獲取指定文檔下的所有留言
        query.getDocuments { (snapshot, error) in
            if let error = error { fatalError(error.localizedDescription) }
            
            // 遍歷查詢結果，逐個刪除留言
            for document in snapshot!.documents {
                let documentID = document.documentID
                let commentRef = query.document(documentID)
                
                // 刪除留言
                commentRef.delete { error in
                    if let error = error { fatalError(error.localizedDescription) }
                }
            }
            // 已成功刪除所有留言
            completion()
        }
    }
    
}






