//
//  ImageDeleter.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/24.
//

import UIKit
import FirebaseStorage

enum ImageDeleter {
}

// MARK: - Delete

extension ImageDeleter {
    
    static func deleteImage(url: String, completion: @escaping () -> Void) {
        Storage.storage().reference(forURL: url).delete { error in
            if let error = error { fatalError(error.localizedDescription) }
            completion()
        }
    }
    
}
