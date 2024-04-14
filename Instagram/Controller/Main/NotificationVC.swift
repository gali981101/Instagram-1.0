//
//  NotificationVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit

private let notificationCellId = K.CellId.notificationCellId

final class NotificationVC: UITableViewController {
    
    // MARK: - Properties
    
    private var notifications: [Notify] = [] {
        didSet { tableView.reloadData() }
    }
    
    private var suggested: [User] = []
    
    // MARK: - UIElement
    
    private lazy var refresher = UIRefreshControl()
}

// MARK: - Life Cycle

extension NotificationVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        fetchNotifications()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchNotifications),
            name: Notification.Name(K.NotificationName.updateNotify),
            object: nil
        )
    }
    
}

// MARK: - Set

extension NotificationVC {
    
    private func config() {
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = K.Title.notifications
        
        tableView.register(
            NotificationCell.self,
            forCellReuseIdentifier: notificationCellId
        )
        
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        tableView.showsVerticalScrollIndicator = false
        
        tableView.refreshControl = refresher
        
        refresher.addTarget(
            self,
            action: #selector(fetchNotifications),
            for: .valueChanged
        )
    }
    
}

// MARK: - @objc Actions

extension NotificationVC {
    
    @objc private func fetchNotifications() {
        NotifyService.fetchNotifications { [unowned self] notifications in
            self.notifications = notifications
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

extension NotificationVC {
    
    private func fetchSuggestedUsers() {
        UserService.fetchAllUsers { [unowned self] users in
            suggested = users
            checkIfSuggestedUserIsFollowed()
        }
    }
    
    private func checkIfUserIsFollowed() {
        let group = DispatchGroup()
        
        notifications.forEach { notify in
            group.enter()
            
            if notify.type == .follow {
                UserService.checkIfUserIsFollowed(uid: notify.uid) { [unowned self] isFollowed in
                    if let i = notifications.firstIndex(where: { $0.id == notify.id }) {
                        self.notifications[i].userIsFollowed = isFollowed
                    }
                    group.leave()
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .global()) { [unowned self] in
            fetchSuggestedUsers()
        }
    }
    
    private func checkIfSuggestedUserIsFollowed() {
        let group = DispatchGroup()
        
        suggested.forEach { user in
            group.enter()
            
            UserService.checkIfUserIsFollowed(uid: user.uid) { [unowned self] isFollowed in
                if let i = suggested.firstIndex(where: { $0.uid == user.uid }) {
                    if isFollowed { suggested.remove(at: i) }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [unowned self] in
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
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

extension NotificationVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? notifications.count : suggested.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: notificationCellId,
            for: indexPath
        ) as! NotificationCell
        
        cell.delegate = self
        
        switch indexPath.section {
        case 0:
            cell.isNotify = true
            cell.notificationVM = NotificationVM(notify: notifications[indexPath.row])
        case 1:
            cell.isNotify = false
            cell.userCellVM = UserCellVM(user: suggested[indexPath.row])
        default:
            break
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension NotificationVC {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width - 30, height: 40))
        
        titleLabel.textColor = .label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .left
        
        titleLabel.text = section == 0 ? K.LabelText.recent : K.LabelText.suggested
        
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
        footerView.backgroundColor = section == 0 ? UIColor.lightGray : .clear
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "") { action, sourceView, completion in
            if let currentUid = AuthService.shared.getCurrentUserUid() {
                NotifyService.deleteNotification(currentUid: currentUid, id: self.notifications[indexPath.row].id) { [unowned self] in
                    notifications.remove(at: indexPath.row)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    completion(true)
                }
            }
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: K.SystemImageName.trash)
        
        return indexPath.section == 0 ?
        UISwipeActionsConfiguration(actions: [deleteAction]) : UISwipeActionsConfiguration(actions: [])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoader(true)
        
        var uid: String = notifications[indexPath.row].uid
        
        if indexPath.section == 1 {
            uid = suggested[indexPath.row].uid
        }
        
        fetchUser(uid: uid)
    }
    
}

// MARK: - NotificationCellDelegate

extension NotificationVC: NotificationCellDelegate {
    
    func cell(_ cell: NotificationCell, wantsToFollow uid: String, isNotify: Bool) {
        showLoader(true)
        
        UserService.follow(uid: uid) { error in
            if let error = error { fatalError(error.localizedDescription) }
            
            self.showLoader(false)
            
            if isNotify {
                cell.notificationVM?.notify.userIsFollowed.toggle()
            } else {
                cell.userCellVM?.user.isFollowed.toggle()
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String, isNotify: Bool) {
        showLoader(true)
        
        UserService.unfollow(uid: uid) { error in
            if let error = error { fatalError(error.localizedDescription) }
            
            self.showLoader(false)
            
            if isNotify {
                cell.notificationVM?.notify.userIsFollowed.toggle()
            } else {
                cell.userCellVM?.user.isFollowed.toggle()
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        let layout = UICollectionViewFlowLayout()
        let singlePostVC = SinglePostVC(postId: postId, layout: layout)
        
        navigationController?.pushViewController(singlePostVC, animated: true)
    }
    
}




















