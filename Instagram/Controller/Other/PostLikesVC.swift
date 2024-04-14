//
//  UserListVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/11.
//

import UIKit

private let notificationCellId = K.CellId.notificationCellId

final class PostLikesVC: UITableViewController {
    
    // MARK: - Properties
    
    private var postId: String
    
    private lazy var users: [User] = []
    
    // MARK: - UIElement
    
    private lazy var refresher = UIRefreshControl()
    
    // MARK: - init
    
    init(postId: String) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension PostLikesVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        fetchLikesUsers()
    }
    
}

// MARK: - Set

extension PostLikesVC {
    
    private func config() {
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = K.Title.likes
        
        tableView.register(
            NotificationCell.self,
            forCellReuseIdentifier: notificationCellId
        )
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.showsVerticalScrollIndicator = false
        
        tableView.refreshControl = refresher
        
        refreshControl?.addTarget(
            self,
            action: #selector(fetchLikesUsers),
            for: .valueChanged
        )
    }
    
}

// MARK: - @objc Actions

extension PostLikesVC {
    
    @objc private func fetchLikesUsers() {
        UserService.fetchPostLikesUsers(postId: postId, limit: 20) { [unowned self] users in
            self.users = users
            checkIfUserIsFollowed()
            
            if refresher.isRefreshing {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [unowned self] in
                    refresher.endRefreshing()
                }
            }
        }
    }
    
}

// MARK: - Service

extension PostLikesVC {
    
    private func checkIfUserIsFollowed() {
        users.forEach { user in
            UserService.checkIfUserIsFollowed(uid: user.uid) { [unowned self] isFollowed in
                guard let i = users.firstIndex(where: { $0.uid == user.uid }) else { return }
                users[i].isFollowed = isFollowed
                
                DispatchQueue.main.async { [unowned self] in tableView.reloadData() }
            }
        }
    }
    
    private func fetchUser(uid: String) {
        UserService.fetchUser(with: uid) { [weak self] user in
            self?.showLoader(false)
            
            let profileVC = ProfileVC(user: user)
            self?.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
}

// MARK: - UITableViewDataSource

extension PostLikesVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: notificationCellId,
            for: indexPath
        ) as! NotificationCell
        
        cell.delegate = self
        
        cell.isNotify = false
        cell.userCellVM = UserCellVM(user: users[indexPath.row])
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension PostLikesVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        fetchUser(uid: users[indexPath.row].uid)
    }
    
}

// MARK: - NotificationCellDelegate

extension PostLikesVC: NotificationCellDelegate {
    
    func cell(_ cell: NotificationCell, wantsToFollow uid: String, isNotify: Bool) {
        showLoader(true)
        
        UserService.follow(uid: uid) { [unowned self] error in
            if let error = error { fatalError(error.localizedDescription) }
            showLoader(false)
            
            cell.userCellVM?.user.isFollowed.toggle()
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String, isNotify: Bool) {
        showLoader(true)
        
        UserService.unfollow(uid: uid) { [unowned self] error in
            if let error = error { fatalError(error.localizedDescription) }
            showLoader(false)
            
            cell.userCellVM?.user.isFollowed.toggle()
        }
    }
    
    // 無需在此方法內撰寫內容，在這邊用不到點擊貼文後，推進到個人主頁的功能
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {}
    
}


















