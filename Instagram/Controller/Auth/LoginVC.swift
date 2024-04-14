//
//  LoginVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit
import FirebaseAuth
import IQKeyboardManagerSwift

final class LoginVC: UIViewController {
    
    // MARK: - Properties
    
    private var vm = LoginVM()
    
    // MARK: - UIElement
    
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: K.ImageName.igLogoWhite)
        )
        
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = TextFieldFactory
            .makeAuthField(K.Placeholder.email)
        
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = TextFieldFactory
            .makeAuthField(K.Placeholder.password)
        
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        textField.returnKeyType = .go
        
        return textField
    }()
    
    private lazy var loginButton: UIButton = {
        let button = ButtonFactory
            .makeAuthButton(K.ButtonTitle.logIn)
        
        button.isEnabled = false
        
        button.addTarget(
            self,
            action: #selector(handleLogIn),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(
            firstPart: K.buttonAttribute.forgotPassword1,
            secondPart: K.buttonAttribute.forgotPassword2
        )
        
        button.addTarget(
            self,
            action: #selector(handleShowResetPassword),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(
            firstPart: K.buttonAttribute.dontHaveAccount1,
            secondPart: K.buttonAttribute.dontHaveAccount2
        )
        
        button.addTarget(
            self,
            action: #selector(showSignUp),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton,
            forgotPasswordButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        return stackView
    }()
    
}

// MARK: - Life Cycle

extension LoginVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        
        AuthService.shared.delegate = self
        configNotificationObservers()
    }
    
}

// MARK: - Set

extension LoginVC {
    
    private func style() {
        IQKeyboardManager.shared.enable = true
        
        configGradientLayer()
        
        navigationController?
            .navigationBar
            .isHidden = true
        
        navigationController?.navigationBar
            .barStyle = .black
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        view.addSubview(iconImage)
        view.addSubview(stackView)
        view.addSubview(dontHaveAccountButton)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
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
        
        dontHaveAccountButton.centerX(inView: view)
        
        dontHaveAccountButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor
        )
    }
    
}

// MARK: - @objc Actions

extension LoginVC {
    
    @objc private func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            vm.email = sender.text
        } else {
            vm.password = sender.text
        }
        
        updateForm()
    }
    
    @objc private func handleLogIn() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        AuthService.shared.logInUser(with: email, password: password) { [unowned self] in
            view.endEditing(true)
            
            NotificationCenter.default.post(
                name: NSNotification.Name(K.NotificationName.updateUser),
                object: nil
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name(K.NotificationName.updatePost),
                object: nil
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name(K.NotificationName.updateNotify),
                object: nil
            )
            
            dismiss(animated: true)
        }
    }
    
    @objc private func showSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc private func handleShowResetPassword() {
        let resetPasswordVC = ResetPasswordVC(delegate: self, email: emailTextField.text)
        navigationController?.pushViewController(resetPasswordVC, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string == " " ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return false
    }
    
}

// MARK: - FormVMDelegate

extension LoginVC: FormVMDelegate {
    
    func updateForm() {
        loginButton.isEnabled = vm.formIsValid
        loginButton.backgroundColor = vm.buttonBgColor
        loginButton.setTitleColor(vm.buttonTitleColor, for: .normal)
    }
    
}

// MARK: - AuthServiceDelegate

extension LoginVC: AuthServiceDelegate {
    
    func sendErrorAlert(error: any Error) {
        let alert = AlertFactory.makeOkAlert(
            title: K.Alert.loginError,
            message: error.localizedDescription
        )
        
        self.present(alert, animated: true)
    }
    
    func sendEmailVerifyAlert() {
        let alert = UIAlertController(
            title: K.Alert.loginError,
            message: K.EmailVerify.logMessage,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: K.EmailVerify.resend, style: .default) { _ in
            Auth.auth().currentUser?.sendEmailVerification()
        }
        
        let cancelAction = UIAlertAction(title: K.Alert.cancel, style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
}

// MARK: - ResetPasswordDelegate

extension LoginVC: ResetPasswordDelegate {
    
    func vcDidSendResetPasswordLink(_ vc: ResetPasswordVC) {
        navigationController?.popViewController(animated: true)
        
        let alert = AlertFactory.makeOkAlert(
            title: K.Alert.success,
            message: K.EmailVerify.resetPasswordSuccess
        )
        
        present(alert, animated: true)
    }
    
}

// MARK: - View Model Methods

extension LoginVC {
    
    private func configNotificationObservers() {
        emailTextField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        
        passwordTextField.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
    }
    
}


