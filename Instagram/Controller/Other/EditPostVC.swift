//
//  EditPostVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/9.
//

import UIKit
import IQKeyboardManagerSwift

private let gridCellIdentifier = K.CellId.gridCellId

// MARK: - EditPostVCDelegate

protocol EditPostVCDelegate: AnyObject {
    func closePostSettingVC()
    func updatePostCaptionText(postId: String)
}

// MARK: - EditPostVC

final class EditPostVC: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: EditPostVCDelegate?
    
    private var vm: PostVM
    
    // MARK: - UIElement
    
    private lazy var cancelButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(handleDismiss)
        )
        
        return barButton
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(handleDoneButtonTapped)
        )
        
        return barButton
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        imageView.backgroundColor = .lightGray
        
        return imageView
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.register(
            GridCell.self,
            forCellWithReuseIdentifier: gridCellIdentifier
        )
        
        cv.backgroundColor = .systemBackground
        
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        
        control.addTarget(
            self,
            action: #selector(changePage),
            for: .valueChanged
        )
        
        control.pageIndicatorTintColor = .gray.withAlphaComponent(0.5)
        control.currentPageIndicatorTintColor = ThemeColor.red3
        
        control.currentPage = 0
        
        return control
    }()
    
    private lazy var captionTextView: InputTextView = {
        let tv = InputTextView()
        
        tv.font = UIFont.preferredFont(forTextStyle: .callout)
        tv.delegate = self
        
        return tv
    }()
    
    // MARK: - init
    
    init(delegate: EditPostVCDelegate?, vm: PostVM) {
        self.delegate = delegate
        self.vm = vm
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension EditPostVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

// MARK: - Set

extension EditPostVC {
    
    private func style() {
        view.backgroundColor = .systemBackground
        
        self.title = K.Title.editPost
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.rightBarButtonItem?.tintColor = ThemeColor.red3
        
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(imageCollectionView)
        view.addSubview(pageControl)
        view.addSubview(captionTextView)
        
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.sd_setImage(with: vm.ownerImageUrl)
        usernameLabel.text = vm.ownerUsername
        
        pageControl.numberOfPages = vm.post.imageUrls.count == 1 ? 0 : vm.post.imageUrls.count
        
        captionTextView.text = vm.caption
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
        profileImageView.setDimensions(height: 40, width: 40)
        
        profileImageView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            paddingTop: 12,
            paddingLeft: 12
        )
        
        usernameLabel.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
        
        imageCollectionView.anchor(
            top: profileImageView.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 8
        )
        
        imageCollectionView.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: 1
        ).isActive = true
        
        pageControl.centerX(
            inView: self.view,
            topAnchor: imageCollectionView.bottomAnchor
        )
        
        pageControl.setWidth(135)
        
        for dot in pageControl.subviews {
            dot.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        }
        
        captionTextView.anchor(
            top: imageCollectionView.bottomAnchor,
            left: view.leftAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            right: view.rightAnchor,
            paddingTop: 16,
            paddingLeft: 12,
            paddingRight: 12
        )
    }
    
}

// MARK: - @objc Methods

extension EditPostVC {
    
    @objc private func handleDismiss() {
        self.dismiss(animated: true) { [weak self] in
            self?.delegate?.closePostSettingVC()
        }
    }
    
    @objc private func handleDoneButtonTapped() {
        PostService.updatePostCaption(postId: vm.postId, text: captionTextView.text) { [weak self] error in
            if let error = error { fatalError(error.localizedDescription) }
            
            self?.delegate?.updatePostCaptionText(postId: self?.vm.postId ?? "")
            self?.handleDismiss()
        }
    }
    
    @objc private func changePage(sender: AnyObject) {
        let x = CGFloat(pageControl.currentPage) * imageCollectionView.frame.size.width
        imageCollectionView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource

extension EditPostVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.post.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: gridCellIdentifier,
            for: indexPath) as! GridCell
        
        if let images = vm.imageUrls {
            cell.postImageView.sd_setImage(with: images[indexPath.item])
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension EditPostVC: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EditPostVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width, height: collectionView.frame.height)
    }
    
}

// MARK: - UITextViewDelegate

extension EditPostVC: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkMaxLength(textView)
    }
    
}

// MARK: - Helper Methods

extension EditPostVC {
    
    private func checkMaxLength(_ textView: UITextView) {
        if (textView.text.count) > 500 { textView.deleteBackward() }
    }
    
}








