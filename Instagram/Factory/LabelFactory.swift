//
//  LabelFactory.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/15.
//

import UIKit

enum LabelFactory {
    
    static func makeStatsLabel(number: Int, text: String) -> UILabel {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.attributedText = attributedStatText(
            value: number,
            label: text
        )
        
        return label
    }
    
}

// MARK: - Helper Methods

extension LabelFactory {
    
    static func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(
            string: "\(value)\n",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
        )
        
        attributedText.append(NSAttributedString(
            string: label,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.lightGray
            ])
        )
        
        return attributedText
    }
    
}
