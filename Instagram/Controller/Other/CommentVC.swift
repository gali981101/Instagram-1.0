//
//  CommentVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/29.
//

import UIKit
import IQKeyboardManagerSwift

private let commentCellId = K.CellId.commentCellId

final class CommentVC: CommentStyleVC {
    
    // MARK: - Properties
    
    private let post: Post
    private var comments: [Comment] = []
    
    fileprivate var isLoadingComment: Bool = false
    
    // MARK: - UIElement
    
    // MARK: - init
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension CommentVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        loadComments()
    }
    
}

// MARK: - Set

extension CommentVC {
    
    private func style() {
        self.title = K.Title.comment
        
        tableView.dataSource = self
        tableView.delegate = self
        
        commentInputView.delegate = self
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
}

// MARK: - Service

extension CommentVC {
    
    private func loadComments() {
        isLoadingComment = true
        
        CommentService.fetchComments(forPost: post, limit: 10) { [weak self] comments in
            self?.comments = comments
            self?.isLoadingComment = false
            
            self?.tableView.reloadData()
            self?.tableView.setContentOffset(.zero, animated: true)
        }
    }
    
    private func loadOldComments(timeStamp: Int) {
        isLoadingComment = true
        
        CommentService.fetchComments(forPost: post, start: timeStamp, limit: 10) { [weak self] oldComments in
            
            var indexPaths: [IndexPath] = []
            
            self?.tableView.beginUpdates()
            
            for comment in oldComments {
                self?.comments.append(comment)
                
                if let comments = self?.comments {
                    let indexPath = IndexPath(item: comments.count - 1, section: 0)
                    indexPaths.append(indexPath)
                }
            }
            
            self?.tableView.insertRows(at: indexPaths, with: .automatic)
            self?.tableView.endUpdates()
            
            self?.isLoadingComment = false
        }
    }
    
}

// MARK: - UITableViewDataSource

extension CommentVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: commentCellId,
            for: indexPath
        ) as! CommentCell
        
        cell.vm = CommentVM(comment: self.comments[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let vm = CommentVM(comment: comments[indexPath.row])
        let height = vm.size(forWidth: view.frame.width).height + 80
        
        return height
    }
    
}

// MARK: - UITableViewDelegate

extension CommentVC {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 在使用者滑到最後兩列時，觸發加載舊留言
        guard !isLoadingComment, (comments.count - indexPath.row) == 2 else { return }
        guard let lastPostTimestamp = comments.last?.timestamp else { return }
        
        loadOldComments(timeStamp: lastPostTimestamp)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [unowned self] action, sourceView, completion in
            CommentService.deleteComment(
                forPost: post,
                commentID: comments[indexPath.row].commentId) { error in
                    if let error = error { fatalError(error.localizedDescription) }
                    tableView.reloadData()
                    completion(true)
                }
        }
        
        let replyAction = UIContextualAction(style: .destructive, title: "") { action, sourceView, completion in
            completion(true)
        }
        
        replyAction.backgroundColor = UIColor.lightGray
        replyAction.image = UIImage(systemName: K.SystemImageName.arrowTurnLeft)
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: K.SystemImageName.trash)
        
        return comments[indexPath.row].uid == AuthService.shared.getCurrentUserUid() ? 
        UISwipeActionsConfiguration(actions: [deleteAction, replyAction]) : UISwipeActionsConfiguration(actions: [replyAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = comments[indexPath.row].uid
        
        UserService.fetchUser(with: uid) { [weak self] user in
            let vc = ProfileVC(user: user)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: - CommentInputAccesoryViewDelegate

extension CommentVC: CommentInputAccesoryViewDelegate {
    
    func inputView(_ inputView: CommentInputAccesoryView, wantsToUploadComment comment: String) {
        showLoader(true)
        
        if comment.isEmpty {
            showLoader(false)
            return
        }
        
        UserService.fetchUser { currentUser in
            CommentService.uploadComment(comment: comment, post: self.post, user: currentUser) { error in
                if let error = error { fatalError(error.localizedDescription) }
                
                self.showLoader(false)
                inputView.clearCommentTextView()
                
                NotifyService.uploadNotification(toUid: self.post.ownerUid, fromUser: currentUser, type: .comment, post: self.post)
            }
        }
    }
    
}





























