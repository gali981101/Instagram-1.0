//
//  CommentInputAccesoryView.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/30.
//

import UIKit
import SDWebImage

protocol CommentInputAccesoryViewDelegate: AnyObject {
    func inputView(_ inputView: CommentInputAccesoryView, wantsToUploadComment comment: String)
}

final class CommentInputAccesoryView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: CommentInputAccesoryViewDelegate?
    
    // MARK: - UIElement
    
    private lazy var commentTextView: InputTextView = {
        let tv = InputTextView()
        
        tv.delegate = self
        
        tv.placeholderShouldCenter = true
        
        tv.placeholderText = K.Placeholder.enterComment
        tv.font = UIFont.systemFont(ofSize: 15)
        
        tv.isScrollEnabled = false
        
        return tv
    }()
    
    private lazy var publishButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(K.ButtonTitle.publish, for: .normal)
        button.setTitleColor(ThemeColor.red3, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(
            self,
            action: #selector(handlePublishTapped),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize { return .zero }
    
}

// MARK: - Set

extension CommentInputAccesoryView {
    
    private func style() {
        self.backgroundColor = .systemBackground
        
        autoresizingMask = .flexibleHeight
        
        addSubview(divider)
        addSubview(commentTextView)
        addSubview(publishButton)
        
        commentTextView.layer.cornerRadius = 10
    }
    
    private func layout() {
        divider.anchor(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            height: 0.5
        )
        
        commentTextView.anchor(
            top: topAnchor,
            left: leftAnchor,
            bottom: safeAreaLayoutGuide.bottomAnchor,
            right: publishButton.leftAnchor,
            paddingTop: 8,
            paddingLeft: 8,
            paddingBottom: 8,
            paddingRight: 8
        )
        
        publishButton.setDimensions(height: 50, width: 50)
        
        publishButton.anchor(
            top: topAnchor,
            right: rightAnchor,
            paddingRight: 12
        )
    }
    
}

// MARK: - Service

extension CommentInputAccesoryView {
}

// MARK: - @objc Actions

extension CommentInputAccesoryView {
    
    @objc private func handlePublishTapped() {
        delegate?.inputView(self, wantsToUploadComment: commentTextView.text)
    }
    
}

// MARK: - UITextViewDelegate

extension CommentInputAccesoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
    }
    
}

// MARK: - Helper Methods

extension CommentInputAccesoryView {
    
    private func checkMaxLength(_ textView: UITextView) {
        if (textView.text.count) > 100 {
            textView.deleteBackward()
        }
    }
    
    func clearCommentTextView() {
        commentTextView.text = nil
        commentTextView.placeholderLabel.isHidden = false
    }
    
}







