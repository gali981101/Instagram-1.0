//
//  SearchVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/11.
//

import UIKit

private let tableViewCellId = K.CellId.userCell
private let gridCellIdentifier = K.CellId.gridCellId

// MARK: - SearchVC

final class SearchVC: UIViewController {
    
    // MARK: - Properties
    
    private var users: [User] = []
    private var posts: [Post] = []
    
    // MARK: - UIElement
    
    private lazy var tableView: UITableView = UITableView()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.showsVerticalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        
        cv.register(GridCell.self, forCellWithReuseIdentifier: gridCellIdentifier)
        
        return cv
    }()
    
    private lazy var refresher = UIRefreshControl()
    
}

// MARK: - Life Cycle

extension SearchVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecentPosts()
    }
    
}

// MARK: - Set

extension SearchVC {
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        collectionView.refreshControl = refresher
        
        refresher.addTarget(
            self,
            action: #selector(loadRecentPosts),
            for: .valueChanged
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UserCell.self, forCellReuseIdentifier: tableViewCellId)
        tableView.rowHeight = 64
        
        tableView.separatorStyle = .none
        
        view.addSubview(collectionView)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = K.Placeholder.search
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = false
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureHandler(_:))
        )
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    private func layout() {
        collectionView.fillSuperview()
        tableView.fillSuperview()
    }
    
}

// MARK: - @objc Actions

extension SearchVC {
    
    @objc private func loadRecentPosts()  {
        PostService.getRecentPosts(limit: 20) { [unowned self] newPosts in
            
            if !(newPosts.isEmpty) {
                posts = newPosts
            } else {
                posts.removeAll()
                collectionView.reloadData()
            }
            
            refresher.endRefreshing()
            
            if !(posts.isEmpty) { checkIfUserLikedPosts() }
        }
    }
    
    @objc private func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: tableView)
        
        if let _ = tableView.indexPathForRow(at: location) {
            // 如果點擊位置位於 tableView cell 上，則不取消 searchController
            return
        }
        
        // 如果點擊位置不位於 tableView cell 上，則取消 searchController
        searchController.isActive = false
        
        addCollectionView()
    }
    
}

// MARK: - Service

extension SearchVC {
    
    private func fetchUsers(username: String, fullname: String, searchText: String) {
        let group = DispatchGroup()
        
        var users1: [User] = []
        var users2: [User] = []
        
        group.enter()
        UserService.fetchUsers(in: username, searchText, limit: 5) { fetchedUsers in
            users1 = fetchedUsers
            group.leave()
        }
        
        group.enter()
        UserService.fetchUsers(in: fullname, searchText, limit: 5) { fetchedUsers in
            users2 = fetchedUsers
            group.leave()
        }
        
        group.notify(queue: .main) { [unowned self] in
            // 在這裡處理兩個異步呼叫完成後的結果
            // 例如，更新 UI 或其他相關操作
            
            var i: Int = 0
            var j: Int = 0
            
            while i <= users1.count - 1 && j <= users2.count - 1 {
                if users1[i].uid == users2[j].uid {
                    users1.remove(at: i)
                    j += 1
                }
                
                i += 1
                j += 1
            }
            
            users = users1 + users2
            tableView.reloadData()
        }
    }
    
    private func checkIfUserLikedPosts() {
        let group = DispatchGroup()
        
        // 遍歷所有貼文並檢查用戶是否已經按讚
        for post in posts {
            group.enter()
            
            PostService.checkIfUserLikedPost(post: post) { [weak self] didLike in
                guard let self = self else { return }
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId } ) {
                    self.posts[index].didLike = didLike
                }
                group.leave()
            }
        }
        
        // 當所有檢查完成後更新 UI
        group.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: gridCellIdentifier,
            for: indexPath
        ) as! GridCell
        
        cell.vm = PostVM(post: self.posts[indexPath.item], indexPath: indexPath)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension SearchVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layOut = UICollectionViewFlowLayout()
        
        let profileFeedVC = ProfileFeedVC(startIndexPath: indexPath, layout: layOut)
        profileFeedVC.userPosts = posts
        
        navigationController?.pushViewController(profileFeedVC, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
}

// MARK: - UITableViewDataSource

extension SearchVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: tableViewCellId,
            for: indexPath
        ) as! UserCell
        
        cell.vm = UserCellVM(user: users[indexPath.row])
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let vc = ProfileVC(user: user)
        
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UISearchControllerDelegate

extension SearchVC: UISearchControllerDelegate {
}

// MARK: - UISearchResultsUpdating

extension SearchVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController
            .searchBar.text?.lowercased() else { return }
        
        if searchText.isEmpty || !(searchController.isActive) {
            users = []
            tableView.reloadData()
        }
        
        fetchUsers(
            username: K.UserProfile.username,
            fullname: K.UserProfile.fullname,
            searchText: searchText
        )
    }
    
}

// MARK: - UISearchBarDelegate

extension SearchVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        addTableView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        addCollectionView()
        
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
}

// MARK: - Helper Methods

extension SearchVC {
    
    private func addCollectionView() {
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        
        tableView.removeFromSuperview()
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        collectionView.removeFromSuperview()
    }
    
}
