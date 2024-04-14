//
//  ResetPasswordVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/4/8.
//

import UIKit

// MARK: - ResetPasswordVC Delegate

protocol ResetPasswordDelegate: AnyObject {
    func vcDidSendResetPasswordLink(_ vc: ResetPasswordVC)
}

// MARK: - ResetPasswordVC

final class ResetPasswordVC: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: ResetPasswordDelegate?
    
    private var vm = ResetPasswordVM()
    
    var email: String?
    
    // MARK: - UIElement
    
    private lazy var emailTextField = TextFieldFactory.makeAuthField(K.Placeholder.email)
    private lazy var iconImage = UIImageView(image: UIImage(named: K.ImageName.igLogoWhite))
    
    private lazy var resetPasswordButton: UIButton = {
        let button = ButtonFactory
            .makeAuthButton(K.ButtonTitle.resetPassword)
        
        button.isEnabled = false
        
        button.addTarget(
            self,
            action: #selector(handleResetPassword),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.tintColor = .white
        button.setImage(UIImage(systemName: K.SystemImageName.chevronLeft), for: .normal)
        
        button.addTarget(
            self,
            action: #selector(handleDismiss),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            resetPasswordButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        return stackView
    }()
    
    // MARK: - init
    
    init(delegate: ResetPasswordDelegate? = nil, email: String? = nil) {
        self.delegate = delegate
        self.email = email
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Life Cycle

extension ResetPasswordVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
    }
    
}

// MARK: - Set

extension ResetPasswordVC {
    
    private func style() {
        configGradientLayer()
        
        view.addSubview(backButton)
        view.addSubview(iconImage)
        view.addSubview(stackView)
        
        iconImage.contentMode = .scaleAspectFill
        
        emailTextField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        
        emailTextField.text = email
        vm.email = email
        
        updateForm()
    }
    
    private func layout() {
        backButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            paddingTop: 16,
            paddingLeft: 16
        )
        
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        
        iconImage.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        
        stackView.anchor(
            top: iconImage.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 32,
            paddingLeft: 32,
            paddingRight: 32
        )
    }
    
}

// MARK: - @objc Actions

extension ResetPasswordVC {
    
    @objc private func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            vm.email = sender.text
        }
        
        updateForm()
    }
    
    @objc private func handleResetPassword() {
        guard let email = emailTextField.text else { return }
        
        showLoader(true)
        
        AuthService.resetPassword(withEmail: email) { error in
            self.showLoader(false)
            
            if let error = error {
                let alert = AlertFactory.makeOkAlert(title: K.Alert.error, message: error.localizedDescription)
                self.present(alert, animated: true)
                return
            }
            
            self.delegate?.vcDidSendResetPasswordLink(self)
        }
    }
    
    @objc private func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - FormVMDelegate

extension ResetPasswordVC: FormVMDelegate {
    
    func updateForm() {
        resetPasswordButton.isEnabled = vm.formIsValid
        resetPasswordButton.backgroundColor = vm.buttonBgColor
        resetPasswordButton.setTitleColor(vm.buttonTitleColor, for: .normal)
    }
    
}














