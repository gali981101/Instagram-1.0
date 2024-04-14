//
//  SignUpVC.swift
//  Instagram
//
//  Created by Terry Jason on 2024/3/12.
//

import UIKit
import PhotosUI
import IQKeyboardManagerSwift

class SignUpVC: UIViewController {
    
    // MARK: - Properties
    
    private var vm = SignUpVM()
    private var profileImage: UIImage?
    
    // MARK: - UIElement
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(
            UIImage(named: K.ImageName.plusPhoto),
            for: .normal
        )
        
        button.tintColor = .white
        
        button.addTarget(
            self,
            action: #selector(handleProfilePhotoSelect),
            for: .touchUpInside
        )
        
        return button
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
        textField.returnKeyType = .next
        
        return textField
    }()
    
    private lazy var fullnameTextField: UITextField = {
        let textField = TextFieldFactory
            .makeAuthField(K.Placeholder.fullname)
        
        textField.returnKeyType = .next
        
        return textField
    }()
    
    private lazy var usernameTextField: UITextField = {
        let textField = TextFieldFactory
            .makeAuthField(K.Placeholder.username)
        
        textField.returnKeyType = .done
        
        return textField
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = ButtonFactory
            .makeAuthButton(K.ButtonTitle.signUp)
        
        button.isEnabled = false
        
        button.addTarget(
            self,
            action: #selector(handleSignUp),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            fullnameTextField,
            usernameTextField,
            signUpButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        
        return stackView
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(
            firstPart: K.buttonAttribute.alreadyHaveAccount1,
            secondPart: K.buttonAttribute.alreadyHaveAccount2
        )
        
        button.addTarget(
            self,
            action: #selector(showLogIn),
            for: .touchUpInside
        )
        
        return button
    }()
    
}

// MARK: - Life Cycle

extension SignUpVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        
        AuthService.shared.delegate = self
        configNotificationObservers()
    }
    
}

// MARK: - Set

extension SignUpVC {
    
    private func style() {
        IQKeyboardManager.shared.enable = true
        
        configGradientLayer()
        
        [emailTextField, passwordTextField, fullnameTextField, usernameTextField]
            .forEach { textField in
                textField.delegate = self
            }
        
        [plusPhotoButton, stackView, alreadyHaveAccountButton]
            .forEach(view.addSubview(_:))
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func layout() {
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        
        plusPhotoButton.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            paddingTop: 32
        )
        
        stackView.anchor(
            top: plusPhotoButton.bottomAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 32,
            paddingLeft: 32,
            paddingRight: 32
        )
        
        alreadyHaveAccountButton.centerX(inView: view)
        
        alreadyHaveAccountButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor
        )
    }
    
}

// MARK: - @objc Actions

extension SignUpVC {
    
    @objc private func handleProfilePhotoSelect() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func textDidChange(sender: UITextField) {
        switch sender {
        case emailTextField:
            vm.email = sender.text
        case passwordTextField:
            vm.password = sender.text
        case fullnameTextField:
            vm.fullname = sender.text
        case usernameTextField:
            vm.username = sender.text
        default:
            break
        }
        
        updateForm()
    }
    
    @objc private func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        guard let profileImage = self.profileImage else { return }
        
        let credentials = AuthCredentials(
            email: email,
            password: password,
            fullname: fullname,
            username: username,
            profileImage: profileImage
        )
        
        AuthService.shared.registerUser(withCredential: credentials) { [unowned self] error in
            if error != nil {
                let alert = AlertFactory.makeOkAlert(
                    message: error!.localizedDescription
                )
                
                self.present(alert, animated: true)
            }
            
            view.endEditing(true)
        }
    }
    
    @objc private func showLogIn() {
        let logInVC = LoginVC()
        navigationController?.pushViewController(logInVC, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension SignUpVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string == " " ? false : true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            fullnameTextField.becomeFirstResponder()
        case fullnameTextField:
            textField.resignFirstResponder()
            usernameTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return false
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension SignUpVC: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        
        guard let itemProvider = itemProviders.first,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        
        itemProvider.loadObject(ofClass: UIImage.self) { [unowned self] (image, error) in
            DispatchQueue.main.async { [unowned self] in
                guard let image = image as? UIImage else { return }
                profileImage = image
                plusPhotoButton.setImage(image
                    .withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
}

// MARK: - FormVMDelegate

extension SignUpVC: FormVMDelegate {
    
    func updateForm() {
        signUpButton.isEnabled = vm.formIsValid
        signUpButton.backgroundColor = vm.buttonBgColor
        signUpButton.setTitleColor(vm.buttonTitleColor, for: .normal)
    }
    
}

// MARK: - AuthServiceDelegate

extension SignUpVC: AuthServiceDelegate {
    
    func sendErrorAlert(error: any Error) {
        let alert = AlertFactory.makeOkAlert(
            message: error.localizedDescription
        )
        
        self.present(alert, animated: true)
    }
    
    func sendEmailVerifyAlert() {
        let alert = UIAlertController(
            title: K.EmailVerify.signTitle,
            message: K.EmailVerify.signMessage,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: K.Alert.ok, style: .cancel) { [unowned self] _ in
            
            let loginVC = LoginVC()
            
            navigationController?.pushViewController(
                loginVC,
                animated: true
            )
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
}

// MARK: - View Model Methods

extension SignUpVC {
    
    private func configNotificationObservers() {
        [emailTextField, passwordTextField, fullnameTextField, usernameTextField]
            .forEach { textField in
                textField.addTarget(
                    self,
                    action: #selector(textDidChange),
                    for: .editingChanged
                )
            }
    }
    
}


