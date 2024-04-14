//
//  UploadPostCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/20.
//

import UIKit

final class UploadPostCell: UICollectionViewCell {
    
    // MARK: - UIElement
    
    lazy var uploadPostImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        
        addSubview(uploadPostImageView)
        
        uploadPostImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

