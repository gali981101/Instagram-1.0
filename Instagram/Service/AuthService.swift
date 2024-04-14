//
//  AuthService.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit
import Firebase
import FirebaseAuth

typealias SendPasswordResetCallback = (Error?) -> Void

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

// MARK: - AuthServiceDelegate

protocol AuthServiceDelegate: AnyObject {
    func sendErrorAlert(error: Error)
    func sendEmailVerifyAlert()
}

// MARK: - AuthService

final class AuthService {
    
    // MARK: - Properties
    
    static let shared: AuthService = AuthService()
    weak var delegate: AuthServiceDelegate?
    
    // MARK: - Init
    
    private init() {}
    
}

// MARK: - Get Current User Id

extension AuthService {
    
    func getCurrentUserUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
}

// MARK: - Log In

extension AuthService {
    
    func logInUser(with email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] result, error in
            if let error = error {
                delegate?.sendErrorAlert(error: error)
                return
            }
            
            guard let result = result, result.user.isEmailVerified else {
                delegate?.sendEmailVerifyAlert()
                return
            }
            
            completion()
        }
    }
    
}

// MARK: - Register

extension AuthService {
    
    func registerUser(withCredential credentials: AuthCredentials, completion: @escaping (Error?) -> Void) {
        
        let email = credentials.email
        let password = credentials.password
        
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self] result, error in
                if error != nil {
                    delegate?.sendErrorAlert(error: error!)
                    return
                }
                
                sendEmailVerify()
                
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = [
                    K.UserProfile.email: credentials.email,
                    K.UserProfile.fullname: credentials.fullname,
                    K.UserProfile.profileImageUrl: imageUrl,
                    K.UserProfile.uid: uid,
                    K.UserProfile.username: credentials.username
                ]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
}

// MARK: - Email Verify

extension AuthService {
    
    private func sendEmailVerify() {
        Auth.auth().currentUser?.sendEmailVerification(completion: { [unowned self] error in
            guard error == nil else { fatalError() }
            delegate?.sendEmailVerifyAlert()
        })
    }
    
}

// MARK: - Reset Password

extension AuthService {
    
    static func resetPassword(withEmail email: String, completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
}




















