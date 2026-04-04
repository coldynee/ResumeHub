//
//  RegistrationView.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation
import UIKit
import SnapKit

final class RegistrationView: UIView {
    
    //MARK: UI components for Registration view
    
    private let contentView: UIView = {
        var view = UIView()
        view.backgroundColor = .primaryBackground
        
        return view
    }()
    
    private let titleView: UIView = {
        var view = UIView()
        view.backgroundColor = .primaryBackgroundInversed
        view.layer.cornerRadius = 50
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ResumeHub"
        label.font = .systemFont(ofSize: 40, weight: .heavy)
        label.textColor = .titleInversed
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "subtitle".localized
        label.font = .systemFont(ofSize: 26)
        label.textColor = .titleInversed
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
    }()
    
    private let registerToGoLabel: UILabel = {
        var label = UILabel()
        label.text = "registerToGo".localized
        label.font = .systemFont(ofSize: 20)
        label.textColor = .primaryBlueContent
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
    }()
    
    private let loginTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "login".localized
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "System", size: 14)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }()
    
    private let emailTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "email".localized
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "System", size: 14)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "password".localized
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "System", size: 14)
        textField.isSecureTextEntry = true
        textField.enablePasswordToggle()
        
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "confirmPassword".localized
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "System", size: 14)
        textField.isSecureTextEntry = true
        textField.enablePasswordToggle()
        
        return textField
    }()
    
    private let errorLabel: UILabel = {
        var label = UILabel()
        label.text = ""
        label.isHidden = true
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
    }()
    
    private let registerButton: UIButton = {
        var button = UIButton()
        button.setTitle("signUp".localized, for: .normal)
        button.backgroundColor = .primaryBackgroundInversed
        button.setTitleColor(.primaryBlueContent, for: .normal)
        button.layer.cornerRadius = 20
        button.alpha = 0.4
        
        return button
    }()
    
    private let haveAccountButton: UIButton = {
        var button = UIButton()
        let attributedString = NSMutableAttributedString(
            string: "haveAccount".localized + " " + "login".localized,
            attributes: [.font: UIFont.systemFont(ofSize: 14)]
        )
        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.primaryBlueContent
            ], range: NSRange (
                location: "haveAccount".localized.count + 1,
                length: "login".localized.count
            ))
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    //MARK: State properties for Register view
    
    private let registerViewBackgroundColor: UIColor = .primaryBackground
    private var activeTextField: UITextField?
    
    //MARK: Callbacks for RegistrationViewContoller
    
    var onLoginChanged: ((String) -> Void)?
    var onEmailChanged: ((String) -> Void)?
    var onPasswordChanged: ((String) -> Void)?
    var onConfirmPasswordChanged: ((String) -> Void)?
    var onHaveAccountTaped: (() -> Void)?
    var onRegisterTaped: (() -> Void)?
    
    //MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        setupActions()
        setupTextFieldDelegates()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Setup UI
    
    private func setupUI() {
        backgroundColor = .primaryBackground
        
        addSubview(contentView)
        
        contentView.addSubview(titleView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(registerToGoLabel)
        contentView.addSubview(loginTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(haveAccountButton)
        contentView.addSubview(registerButton)
    }
    
    //MARK: Constraints
    
    private func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().dividedBy(3.5)
        }
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(titleView.snp.centerY).offset(20)
            $0.centerX.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottomMargin).offset(10)
            $0.centerX.equalToSuperview()
        }
        registerToGoLabel.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.top.equalTo(titleView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        loginTextField.snp.makeConstraints {
            $0.top.equalTo(registerToGoLabel.snp.bottom).offset(15)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(loginTextField.snp.bottomMargin).offset(8)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottomMargin).offset(8)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        confirmPasswordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottomMargin).offset(8)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        registerButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(50)
            $0.trailing.leading.equalToSuperview().inset(50)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(confirmPasswordTextField.snp.bottomMargin).offset(20)
            $0.trailing.leading.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
        }
        haveAccountButton.snp.makeConstraints {
            $0.bottom.equalTo(registerButton.snp.top).offset(-20)
            $0.height.equalTo(30)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(errorLabel.snp.bottom).offset(16)
        }
    }
    
    //MARK: Setup actions
    private func setupActions() {
        loginTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        haveAccountButton.addTarget(self, action: #selector(haveAccountButtonTaped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTaped), for: .touchUpInside)
    }
    
    private func setupTextFieldDelegates() {
        loginTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    //MARK: Validation
    
    private func validateFields() -> Bool {
        let loginText = getLogin()
        let emailText = getEmail()
        let passwordText = getPassword()
        let confirmPasswordText = getConfirmPassword()
        
        guard !loginText.isEmpty, !emailText.isEmpty, !passwordText.isEmpty, !confirmPasswordText.isEmpty else { return false }
        
        return isValidLogin(loginText) && isValidPassword(passwordText) && isValidEmail(emailText) && passwordText == confirmPasswordText
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "[A-Z0-9a-z!_-]{8,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    func isValidLogin(_ login: String) -> Bool {
        let loginRegex = "[A-Z0-9a-z]{3,20}"
        let loginPredicate = NSPredicate(format: "SELF MATCHES %@", loginRegex)
        return loginPredicate.evaluate(with: login)
    }
    
    //MARK: Public methods
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            registerButton.isEnabled = false
            registerButton.setTitle("processing".localized, for: .normal)
        } else {
            registerButton.isEnabled = validateFields()
            registerButton.setTitle("signUp".localized, for: .normal)
        }
    }
    
    func showError(_ message: String?) {
        if let message = message, !message.isEmpty {
            errorLabel.text = message
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
    
    func getLogin() -> String {
        return loginTextField.text ?? ""
    }
    func getEmail() -> String {
        return emailTextField.text ?? ""
    }
    func getPassword() -> String {
        return passwordTextField.text ?? ""
    }
    func getConfirmPassword() -> String {
        return confirmPasswordTextField.text ?? ""
    }
    
    func clearFields() {
        loginTextField.text = nil
        emailTextField.text = nil
        passwordTextField.text = nil
        confirmPasswordTextField.text = nil
        showError(nil)
        updateRegisterButtonState()
    }
    func updateRegisterButtonState() {
        registerButton.isEnabled = validateFields()
        registerButton.alpha = registerButton.isEnabled ? 1 : 0.4
    }
    
    //MARK: Actions
    
    @objc private func textFieldChanged() {
        updateRegisterButtonState()
        onLoginChanged?(loginTextField.text ?? "")
        onEmailChanged?(emailTextField.text ?? "")
        onPasswordChanged?(passwordTextField.text ?? "")
        onConfirmPasswordChanged?(confirmPasswordTextField.text ?? "")
    }
    
    @objc private func registerButtonTaped() {
        onRegisterTaped?()
    }
    @objc private func haveAccountButtonTaped() {
        onHaveAccountTaped?()
    }
}

//MARK: UITextFieldDelegate

extension RegistrationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case loginTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            if registerButton.isEnabled { onRegisterTaped?() }
        default:
            textField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        textField.layer.borderColor = UIColor.primaryBlueContent.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        textField.layer.borderWidth = 0
        updateRegisterButtonState()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        emailTextField.keyboardType = .emailAddress
        passwordTextField.textContentType = .password
        confirmPasswordTextField.textContentType = .password
        return true
    }
}
