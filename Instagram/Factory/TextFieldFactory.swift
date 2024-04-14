//
//  TextFieldFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit

enum TextFieldFactory {
    
    static func makeAuthField(_ placeholder: String) -> UITextField {
        let textField = UITextField()
        
        textField.backgroundColor = ThemeColor.white0
        
        textField.layer.cornerRadius = 10
        textField.setHeight(50)
        
        textField.borderStyle = .none
        
        textField.textColor = .white
        textField.tintColor = .white
        
        textField.keyboardAppearance = .dark
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: ThemeColor.white1
            ]
        )
        
        let spacer = UIView()
        spacer.setDimensions(height: 50, width: 12)
        
        textField.leftView = spacer
        textField.leftViewMode = .always
        
        return textField
    }
    
}

