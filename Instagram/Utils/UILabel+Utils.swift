//
//  UILabel+Utils.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/25.
//

import UIKit

extension UILabel {
    
    func textHeight(withWidth width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.height(withWidth: UIScreen.main.bounds.width, font: UIFont.systemFont(ofSize: 17))
    }
    
}
