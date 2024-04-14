//
//  ImageUploader.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit
import FirebaseStorage

enum ImageUploader {
    
    // MARK: - Firebase Storage Ref
    
    static let PROFILE_PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child(K.FStorage.profile)
    static let POSTS_PHOTO_STORAGE_REF: StorageReference = Storage.storage().reference().child(K.FStorage.posts)
    
}

// MARK: - Upload

extension ImageUploader {
    
    static func uploadImage(image: UIImage, isPost: Bool = false, completionHandler: @escaping (String) -> Void) {
        
        var ref = PROFILE_PHOTO_STORAGE_REF
        
        // 如果是上傳貼文照片，則變更參考路徑
        if isPost { ref = POSTS_PHOTO_STORAGE_REF }
        
        // 使用唯一個 key 作為圖片名稱
        let filename = NSUUID().uuidString
        
        // 準備 Storage 參照
        let imageStorageRef = ref.child("\(filename).jpg")
        
        // 調整圖片大小
        let scaledImage = image.scale(newWidth: 640.0)
        
        guard let imageData = scaledImage.jpegData(compressionQuality: 1) else { return }
        
        // 建立檔案元資料
        let metadata = StorageMetadata()
        metadata.contentType = K.FStorage.contentType
        
        // 準備上傳任務
        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata) { metadata, error in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            imageStorageRef.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else { return }
                completionHandler(imageUrl)
            }
        }
        
        // 顯示上傳進度
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("上傳 \(filename).jpg... \(percentComplete)% 完成")
        }
        
    }
    
}


