//
//  UIButton+Utils.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit

private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

extension UIButton {
    
    func attributedTitle(firstPart: String, secondPart: String) {
        let atts: [NSAttributedString.Key: Any] = [
            .foregroundColor: ThemeColor.white1,
            .font: UIFont.systemFont(ofSize: 16)
        ]
        
        let attributedTitle = NSMutableAttributedString(
            string: "\(firstPart) ",
            attributes: atts
        )
        
        let boldAtts: [NSAttributedString.Key: Any] = [
            .foregroundColor: ThemeColor.white1,
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
        attributedTitle.append(NSAttributedString(
            string: secondPart,
            attributes: boldAtts)
        )
        
        setAttributedTitle(attributedTitle, for: .normal)
    }
    
    func animateHeart() {
        giveFeedback()
        
        // 放大動畫
        let pulse = CABasicAnimation(keyPath: K.Animation.tScale)
        pulse.duration = 0.2
        pulse.fromValue = 1.0
        pulse.toValue = 1.4
        pulse.autoreverses = true
        layer.add(pulse, forKey: K.Animation.pulse)
        
        // ❤️ 型動畫
        let heartImage = UIImage(systemName: K.SystemImageName.heartFill)
        setImage(heartImage, for: .normal)
        tintColor = .red
        
        let heartBeat = CABasicAnimation(keyPath: K.Animation.tScale)
        heartBeat.duration = 0.2
        heartBeat.fromValue = 0.8
        heartBeat.toValue = 1.0
        heartBeat.autoreverses = true
    }
    
}

// MARK: - Helper Methods

extension UIButton {
    
    func giveFeedback() {
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
    
}

