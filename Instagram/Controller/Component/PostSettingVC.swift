//
//  PostSettingVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/23.
//

import UIKit

protocol PostSettingDelegate: AnyObject {
    func deletePost(postId: String)
    func deleteProfilePost(postId: String)
    func updateEditedPost(postId: String)
}

// MARK: - PostSettingVC

final class PostSettingVC: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: PostSettingDelegate?
    
    private var performVC: String
    private var ownerUid: String
    private var postId: String
    
    private var post: Post!
    
    private var vm: PostSettingVM
    
    // MARK: - UIElement
    
    private lazy var tableView: UITableView = {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height
        )
        
        let tv = UITableView(frame: frame, style: .insetGrouped)
        
        tv.dataSource = self
        tv.delegate = self
        
        return tv
    }()
    
    // MARK: - init
    
    init(performVC: String, ownerUid: String, postId: String) {
        self.performVC = performVC
        self.ownerUid = ownerUid
        self.postId = postId
        
        self.vm = PostSettingVM(id: ownerUid)
        
        super.init(nibName: nil, bundle: nil)
        
        PostService.fetchPost(postId: postId) { post in
            self.post = post
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension PostSettingVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
}

// MARK: - Set

extension PostSettingVC {
    
    private func style() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }
    
    private func layout() {
        tableView.fillSuperview()
    }
    
}

// MARK: - UITableViewDataSource

extension PostSettingVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var content = cell.defaultContentConfiguration()
        
        content.image = vm.images[indexPath.row]
        content.text = vm.items[indexPath.row]
        
        cell.tintColor = indexPath.row == 3 ? .red : .label
        
        cell.contentConfiguration = content
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension PostSettingVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 2:
            let editVC = EditPostVC(delegate: self, vm: PostVM(post: post, indexPath: indexPath))
            
            let navVC = UINavigationController(rootViewController: editVC)
            navVC.modalPresentationStyle = .fullScreen
            
            self.present(navVC, animated: true)
        case 3:
            let alert = UIAlertController(
                title: K.Alert.deletePost,
                message: "",
                preferredStyle: .alert
            )
            
            let delete = UIAlertAction(title: K.Alert.delete, style: .destructive) { [unowned self] _ in
                if performVC == K.VCName.feed {
                    delegate?.deletePost(postId: postId)
                } else {
                    delegate?.deleteProfilePost(postId: postId)
                }
                
                self.dismiss(animated: true)
            }
            
            delete.titleTextColor = ThemeColor.red3
            
            let cancel = UIAlertAction(title: K.Alert.cancel, style: .cancel)
            cancel.titleTextColor = .label
            
            alert.addAction(delete)
            alert.addAction(cancel)
            
            self.present(alert, animated: true)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - EditPostVCDelegate

extension PostSettingVC: EditPostVCDelegate {
    
    func closePostSettingVC() {
        self.dismiss(animated: true)
    }
    
    func updatePostCaptionText(postId: String) {
        delegate?.updateEditedPost(postId: postId)
    }
    
}












