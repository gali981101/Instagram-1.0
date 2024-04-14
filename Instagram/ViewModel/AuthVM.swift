//
//  AuthVM.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit

protocol FormVMDelegate {
    func updateForm()
}

protocol AuthVMDelegate {
    var formIsValid: Bool { get }
    var buttonBgColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}

extension AuthVMDelegate {
    var buttonBgColor: UIColor {
        return formIsValid ? ThemeColor.red2 : ThemeColor.red2.withAlphaComponent(0.5)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.64)
    }
}

struct LoginVM: AuthVMDelegate {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
}

struct SignUpVM: AuthVMDelegate {
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false
    }
}

struct ResetPasswordVM: AuthVMDelegate {
    var email: String?
    
    var formIsValid: Bool { return email?.isEmpty == false }
    
    
}






















