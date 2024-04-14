//
//  InputTextView.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/20.
//

import UIKit

class InputTextView: UITextView {
    
    // MARK: - Properties
    
    var placeholderText: String? {
        didSet {
            placeholderLabel.text = placeholderText
        }
    }
    
    var placeholderShouldCenter: Bool = true {
        didSet {
            if placeholderShouldCenter {
                placeholderLabel.centerY(inView: self)
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
            } else {
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
            }
        }
    }
    
    // MARK: - UIElement
    
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextDidChange),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - @objc Actions

extension InputTextView {
    
    @objc private func handleTextDidChange() {
        placeholderLabel.isHidden = !(text.isEmpty)
    }
    
}















