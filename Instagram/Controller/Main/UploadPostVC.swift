//
//  UploadPostVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/20.
//

import UIKit
import IQKeyboardManagerSwift

private let uploadPostCellId = K
    .CellId
    .uploadPostCellId

// MARK: - UploadPostVCDelegate

protocol UploadPostVCDelegate: AnyObject {
    func controllerDidDismiss(_ vc: UploadPostVC)
}

// MARK: - UploadPostVC

final class UploadPostVC: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: UploadPostVCDelegate?
    
    private var currentUser: User?
    private var selectedImages: [UIImage]?
    
    // MARK: - UIElement
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(
            UploadPostCell.self,
            forCellWithReuseIdentifier: uploadPostCellId
        )
        
        cv.backgroundColor = .systemBackground
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    private lazy var captionTextView: InputTextView = {
        let tv = InputTextView()
        
        tv.placeholderShouldCenter = false
        
        tv.placeholderText = K.Placeholder.enterCaption
        tv.font = UIFont.preferredFont(forTextStyle: .callout)
        
        tv.delegate = self
        
        return tv
    }()
    
    private lazy var characterCountLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .lightGray
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.text = K.LabelText.characterCount
        
        return label
    }()
    
    // MARK: - init
    
    init(selectedImages: [UIImage]? = nil) {
        self.selectedImages = selectedImages
        super.init(nibName: nil, bundle: nil)
        
        imageCollectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension UploadPostVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        fetchUser()
    }
    
}

// MARK: - Set

extension UploadPostVC {
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = K.Title.uploadPost
        
        view.addSubview(imageCollectionView)
        view.addSubview(captionTextView)
        view.addSubview(characterCountLabel)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Share",
            style: .done,
            target: self,
            action: #selector(didTapDone)
        )
        
        navigationItem.rightBarButtonItem?.tintColor = ThemeColor.red3
        
        imageCollectionView.delegate = self
        imageCollectionView.layer.cornerRadius = 10
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
        imageCollectionView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 12,
            paddingLeft: 12,
            paddingRight: 12,
            height: 260
        )
        
        captionTextView.anchor(
            top: imageCollectionView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 16,
            paddingLeft: 12,
            paddingRight: 12,
            height: 150
        )
        
        characterCountLabel.anchor(
            bottom: captionTextView.bottomAnchor,
            right: view.rightAnchor,
            paddingBottom: -20,
            paddingRight: 12
        )
    }
    
}

// MARK: - @objc Actions

extension UploadPostVC {
    
    @objc private func didTapCancel() {
        delegate?.controllerDidDismiss(self)
    }
    
    @objc private func didTapDone() {
        guard let images = selectedImages else { return }
        guard let caption = captionTextView.text else { return }
        guard let user = currentUser else { return }
        
        showLoader(true)
        
        PostService.uploadPost(
            caption: caption,
            images: images, 
            owner: user) { [unowned self] error in
                showLoader(false)
                if error != nil { fatalError() }
                
                NotificationCenter.default.post(
                    name: NSNotification.Name(K.NotificationName.updatePost),
                    object: nil
                )
                
                delegate?.controllerDidDismiss(self)
            }
    }
    
}

// MARK: - UICollectionViewDataSource

extension UploadPostVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: uploadPostCellId,
            for: indexPath
        ) as! UploadPostCell
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 10
        
        cell.uploadPostImageView.image = selectedImages?[indexPath.item]
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension UploadPostVC: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UploadPostVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width:  imageCollectionView.frame.width / 1.5,
            height: imageCollectionView.frame.height
        )
    }
    
}

// MARK: - UITextViewDelegate

extension UploadPostVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        beginEditingLayout()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
        
        let count = textView.text.count
        characterCountLabel.text = "\(count)/500"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        endEditingLayout()
    }
    
}

// MARK: - Helper Methods

extension UploadPostVC {
    
    private func fetchUser() {
        UserService.fetchUser { user in
            self.currentUser = user
        }
    }
    
    private func checkMaxLength(_ textView: UITextView) {
        if (textView.text.count) > 500 {
            textView.deleteBackward()
        }
    }
    
    private func beginEditingLayout() {
        navigationItem.title = K.Title.photoCaption
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        
        imageCollectionView.removeFromSuperview()
        
        captionTextView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingLeft: 12,
            paddingRight: 12
        )
    }
    
    private func endEditingLayout() {
        captionTextView.removeFromSuperview()
        style()
        layout()
        
        self.view.layoutIfNeeded()
    }
    
}


























