//
//  AlertControllerFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit

enum AlertFactory {
    
    static func makeOkAlert(title: String = K.Alert.signUpError, message: String) -> UIAlertController {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: K.Alert.ok, style: .cancel)
        
        alert.addAction(okAction)
        
        return alert
    }
    
}

 
