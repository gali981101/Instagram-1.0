//
//  UIAlertAction+Utils.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/24.
//

import UIKit

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}

