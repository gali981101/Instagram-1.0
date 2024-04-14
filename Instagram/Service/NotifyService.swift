//
//  NotifyService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/5.
//

import Firebase

// MARK: - Upload Notification

enum NotifyService {
    
    static func uploadNotification(
        toUid uid: String,
        fromUser: User,
        type: NotifyType,
        post: Post? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection(K.Notify.userNotify).document()
        
        var data: [String: Any] = [
            K.Notify.id: docRef.documentID,
            K.Notify.timestamp: Int(Date().timeIntervalSince1970 * 1000),
            K.Notify.uid: currentUid,
            K.Notify.username: fromUser.username,
            K.Notify.userImageUrl: fromUser.profileImageUrl,
            K.Notify.type: type.rawValue
        ]
        
        if let post = post {
            data[K.Notify.postId] = post.postId
            data[K.Notify.postImageUrl] = post.imageUrls.first
        }
        
        docRef.setData(data)
        
        // 呼叫 completion block（如果存在）
        completion?()
    }
    
}

// MARK: - Delete Notification

extension NotifyService {
    
    static func deleteNotification(currentUid uid: String, id: String, completion: @escaping() -> Void) {
        COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection(K.Notify.userNotify)
            .document(id).delete { error in
                if error != nil { fatalError(error.debugDescription) }
                completion()
            }
    }
    
}

// MARK: - Fetch Notifications

extension NotifyService {
    
    static func fetchNotifications(completion: @escaping([Notify]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS
            .document(uid)
            .collection(K.Notify.userNotify)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                var notifications = documents.map({ Notify(dict: $0.data()) })
                
                notifications.sort(by: { $0.timestamp > $1.timestamp })
                completion(notifications)
            }
    }
    
}
