//
//  UIViewController+Utils.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit
import JGProgressHUD

extension UIViewController {
    
    static let hud = JGProgressHUD(style: .dark)
    
    func configGradientLayer() {
        let gradient = CAGradientLayer()
        
        gradient.colors = [
            UIColor.systemPink.cgColor,
            UIColor.systemOrange.cgColor
        ]
        
        gradient.locations = [0, 1]
        
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
    func showLoader(_ show: Bool) {
        view.endEditing(true)
        
        if show {
            Self.hud.show(in: view)
        } else {
            Self.hud.dismiss()
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - @objc Methods
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
