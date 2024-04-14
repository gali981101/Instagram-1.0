//
//  ProfileCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/14.
//

import UIKit
import SDWebImage

class GridCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var vm: PostVM? {
        didSet { config() }
    }
    
    // MARK: - UIElement
    
    lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        
        addSubview(postImageView)
        
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Helper Methods

extension GridCell {
    
    private func config() {
        guard let vm = vm else { return }
        postImageView.sd_setImage(with: vm.imageUrls?.first)
    }
    
}
