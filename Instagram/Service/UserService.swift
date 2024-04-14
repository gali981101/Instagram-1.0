//
//  UserService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/17.
//

import Firebase

typealias FirestoreCompletion = (Error?) -> Void

// MARK: - Fetch User

enum UserService {
    
    static func fetchUser(with userId: String? = nil, completion: @escaping (User) -> Void) {
        
        let uid = (userId != nil) ? userId : Auth.auth().currentUser?.uid
        
        guard let uid = uid else { return }
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            if error != nil { fatalError(error.debugDescription) }
            
            guard let snapshot = snapshot else { fatalError() }
            guard let dict = snapshot.data() else { fatalError() }
            
            let user = User(dict: dict)
            
            completion(user)
        }
    }
    
}

// MARK: - Fetch Users

extension UserService {
    
    static func fetchUsers(in field: String, _ searchText: String, limit: Int, completion: @escaping ([User]) -> Void) {
        
        if !(searchText.isEmpty) {
            COLLECTION_USERS
                .whereField(field, isGreaterThanOrEqualTo: searchText)
                .whereField(field, isLessThanOrEqualTo: searchText + "\u{f8ff}")
                .limit(to: limit).getDocuments { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    let users = snapshot.documents.map { User(dict: $0.data()) }
                    completion(users)
                }
        }
    }
    
    static func fetchAllUsers(completion: @escaping ([User]) -> Void) {
        let currentUid: String? = Auth.auth().currentUser?.uid
        guard let currentUid = currentUid else { return }
        
        COLLECTION_USERS
            .whereField(K.UserProfile.uid, isNotEqualTo: currentUid)
            .limit(to: 15)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else { return }
                let users = snapshot.documents.map { User(dict: $0.data()) }
                completion(users)
            }
    }
    
}

// MARK: - Fetch Post-Likes Users

extension UserService {
    
    static func fetchPostLikesUsers(postId: String, limit: Int, completion: @escaping ([User]) -> Void) {
        
        let query = COLLECTION_POSTS
            .document(postId)
            .collection(K.Post.postLikes)
            .limit(to: limit)
        
        var users: [User] = []
        
        query.getDocuments { snapshot, error in
            if let error = error { fatalError(error.localizedDescription) }
            guard let documents = snapshot?.documents else { fatalError() }
            
            for document in documents {
                fetchUser(with: document.documentID) { user in
                    if user.uid != Auth.auth().currentUser?.uid { users.append(user) }
                    completion(users)
                }
            }
        }
    }
    
}

// MARK: - Follow User

extension UserService {
    
    static func follow(uid: String, completion: @escaping (FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        COLLECTION_FOLLOWING.document(currentUid).collection(K.Follow.userFollowing).document(uid).setData([:]) { error in
            if let error = error { fatalError(error.localizedDescription) }
            group.leave()
        }
        
        group.enter()
        COLLECTION_FOLLOWERS.document(uid).collection(K.Follow.userFollowers).document(currentUid).setData([:]) { error in
            completion(error)
            group.leave()
        }
        
        group.notify(queue: .main) {}
    }
    
}

// MARK: - Unfollow User

extension UserService {
    
    static func unfollow(uid: String, completion: @escaping (FirestoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let group = DispatchGroup()
        
        group.enter()
        COLLECTION_FOLLOWING.document(currentUid).collection(K.Follow.userFollowing).document(uid).delete { error in
            if let error = error { fatalError(error.localizedDescription) }
            group.leave()
        }
        
        group.enter()
        COLLECTION_FOLLOWERS.document(uid).collection(K.Follow.userFollowers).document(currentUid).delete { error in
            completion(error)
            group.leave()
        }
        
        group.notify(queue: .main) {}
    }
    
}

// MARK: - Check User Follow

extension UserService {
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_FOLLOWING.document(currentUid).collection(K.Follow.userFollowing).document(uid).getDocument { snapshot, error in
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
}

// MARK: - Fetch User Stats

extension UserService {
    
    static func fetchUserStats(uid: String, completion: @escaping (UserStats) -> Void) {
        
        let group = DispatchGroup()
        
        var followers: Int = 0
        var followings: Int = 0
        var posts: Int = 0
        
        group.enter()
        COLLECTION_FOLLOWERS.document(uid).collection(K.Follow.userFollowers).getDocuments { snapshot, _ in
            followers = snapshot?.documents.count ?? 0
            group.leave()
        }
        
        group.enter()
        COLLECTION_FOLLOWING.document(uid).collection(K.Follow.userFollowing).getDocuments { snapshot, _ in
            followings = snapshot?.documents.count ?? 0
            group.leave()
        }
        
        group.enter()
        COLLECTION_POSTS.whereField(K.Post.ownerUid, isEqualTo: uid).getDocuments { snapshot, _ in
            posts = snapshot?.documents.count ?? 0
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(UserStats(followers: followers, followings: followings, posts: posts))
        }
        
    }
    
}

// MARK: - Fetch Followers

extension UserService {
    
    static func fetchFollwers(isFollowerPage: Bool, uid: String, limit: Int, completion: @escaping ([User]) -> Void) {
        
        var query = COLLECTION_FOLLOWERS
            .document(uid)
            .collection(K.Follow.userFollowers)
            .limit(to: limit)
        
        if !isFollowerPage {
            query = COLLECTION_FOLLOWING
                .document(uid)
                .collection(K.Follow.userFollowing)
                .limit(to: limit)
        }
        
        var users: [User] = []
        
        query.getDocuments { snapshot, error in
            if let error = error { fatalError(error.localizedDescription) }
            guard let documents = snapshot?.documents else { fatalError() }
            
            for document in documents {
                fetchUser(with: document.documentID) { user in
                    users.append(user)
                    completion(users)
                }
            }
        }
    }
    
}














