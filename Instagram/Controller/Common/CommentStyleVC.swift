//
//  CommentStyleVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/29.
//

import UIKit

private let commentCellId = K.CellId.commentCellId

class CommentStyleVC: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - UIElement
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        
        tv.delegate = self
        
        tv.backgroundColor = .systemBackground
        
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        tv.register(
            CommentCell.self,
            forCellReuseIdentifier: commentCellId
        )
        
        return tv
    }()
    
    lazy var commentInputView: CommentInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cv = CommentInputAccesoryView(frame: frame)
        return cv
    }()
    
}

// MARK: - Life Cycle

extension CommentStyleVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
}

// MARK: - Set

extension CommentStyleVC {
    
    private func configUI() {
        view.backgroundColor = .systemBackground
        self.view.addSubview(tableView)
        
        tableView.fillSuperview()
        
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .interactive
    }
    
}

// MARK: - UITableViewDelegate

extension CommentStyleVC: UITableViewDelegate {
}
















