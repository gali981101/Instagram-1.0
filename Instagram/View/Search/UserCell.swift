//
//  UserCell.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/18.
//

import UIKit
import SDWebImage

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var vm: UserCellVM? {
        didSet {
            guard oldValue?.user.uid != vm?.user.uid else { return }
            configure()
        }
    }
    
    // MARK: - UIElement
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            usernameLabel,
            fullnameLabel
        ])
        
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 4
        
        return view
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configUI()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Set

extension UserCell {
    
    private func configUI() {
        addSubview(profileImageView)
        addSubview(stackView)
        
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
    }
    
    private func layout() {
        profileImageView.centerY(
            inView: self,
            leftAnchor: leftAnchor,
            paddingLeft: 12
        )
        
        stackView.centerY(
            inView: profileImageView,
            leftAnchor: profileImageView.rightAnchor,
            paddingLeft: 8
        )
    }
    
}

// MARK: - Helper Methods

extension UserCell {
    
    private func configure() {
        guard let vm = vm else { return }
        
        usernameLabel.text = vm.username
        fullnameLabel.text = vm.fullname
        
        profileImageView.sd_setImage(with: vm.profileImageUrl) { image, error, _, url in
            if error != nil { fatalError(error.debugDescription) }
        }
    }
    
}
