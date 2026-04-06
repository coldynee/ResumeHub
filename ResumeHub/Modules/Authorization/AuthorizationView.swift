//
//  AuthorizationView.swift
//  ResumeHub
//
//  Created by Никита Морозов on 27.03.2026.
//

import UIKit
import SnapKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

final class AuthorizationView: UIView {
    
    //MARK: UI components for AuthorizationView
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackground
        
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
    
    private let titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBackgroundInversed
        view.layer.cornerRadius = 50
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        
        return view
    }()
    
    private let authToContinueLabel: UILabel = {
        let label = UILabel()
        label.text = "authToContinue".localized
        label.font = .systemFont(ofSize: 20)
        label.textColor = .primaryBlueContent
        label.textAlignment = .center
        label.sizeToFit()
        
        return label
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedString = NSMutableAttributedString(
            string: "dontHaveAccount".localized + " " + "signUp".localized,
            attributes: [.font: UIFont.systemFont(ofSize: 14)]
        )
        attributedString.addAttributes(
            [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.primaryBlueContent
            ],
            range: NSRange(
                location: "dontHaveAccount".localized.count + 1,
                length: "signUp".localized.count
            )
        )
        
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private let authTypeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["login".localized, "email".localized])
        segment.selectedSegmentIndex = 0
        
        return segment
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "emailInput".localized
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        textField.font = UIFont(name: "System", size: 14)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }()
    
    private let loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "loginInput".localized
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "System", size: 14)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "passwordInput".localized
        textField.borderStyle = .roundedRect
        textField.font = UIFont(name: "System", size: 14)
        textField.isSecureTextEntry = true
        textField.textContentType = .oneTimeCode
        textField.enablePasswordToggle()
        
        return textField
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("forgotPassword".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.primaryBlueContent, for: .normal)
        
        return button
    }()
    
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("loginSign".localized, for: .normal)
        button.setTitleColor(.primaryBackground, for: .normal)
        button.backgroundColor = .primaryBackgroundInversed
        button.layer.cornerRadius = 20
        button.alpha = 0.4
        
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        label.sizeToFit()
        
        return label
    }()
    
    //MARK: State properties for view
    
    
    private let authViewBackgroundColor: UIColor = .primaryBackground
    private var activeTextField: UITextField?
    
    //MARK: Callbacks for AuthorizationViewController
    
    var onAuthTypeChanged: ((Bool) -> Void)?
    var onLoginChanged: ((String) -> Void)?
    var onEmailChanged: ((String) -> Void)?
    var onPasswordChanged: ((String) -> Void)?
    var onForgotPasswordTaped: (() -> Void)?
    var onSignInButtonTaped: (() -> Void)?
    var onRegisterTaped: (() -> Void)?
    
    //MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        setupActions()
        setupTextFieldDelegates()
        animateElements()
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
        contentView.addSubview(authToContinueLabel)
        contentView.addSubview(authTypeSegment)
        contentView.addSubview(emailTextField)
        contentView.addSubview(loginTextField)
        contentView.addSubview(passwordTextField)
        
        
        contentView.addSubview(forgotPasswordButton)
        
        contentView.addSubview(errorLabel)
        
        
        contentView.addSubview(registerButton)
        
        contentView.addSubview(loginButton)
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
        authToContinueLabel.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(titleView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        authTypeSegment.snp.makeConstraints {
            $0.top.equalTo(authToContinueLabel.snp.bottom).offset(15)
            $0.trailing.leading.equalToSuperview().inset(100)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(authTypeSegment.snp.bottom).offset(35)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        loginTextField.snp.makeConstraints {
            $0.top.equalTo(authTypeSegment.snp.bottom).offset(35)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(loginTextField.snp.bottomMargin).offset(8)
            $0.trailing.leading.equalToSuperview().inset(40)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        forgotPasswordButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(15)
        }
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(forgotPasswordButton.snp.bottomMargin).offset(20)
            $0.trailing.leading.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        loginButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(50)
            $0.trailing.leading.equalToSuperview().inset(50)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
        }
        registerButton.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(10)
            $0.bottom.equalTo(loginButton.snp.top).offset(-20)
        }
    }
    
    //MARK: Animations
    private func animateElements() {
        let elements = [authToContinueLabel, authTypeSegment, loginTextField,
                                       emailTextField, passwordTextField, forgotPasswordButton,
                                       loginButton, registerButton]
        elements.forEach { element in
            element.alpha = 0
            element.transform = CGAffineTransform(translationX: 0, y: 30)
        }
        for (index, element) in elements.enumerated() {
            UIView.animate(withDuration: 0.5, delay: 0.1 * Double(index)) {
                if index == 6 {
                    element.alpha = 0.4
                } else {
                    element.alpha = 1
                    element.transform = .identity
                }
            }
        }
    }
    
    //MARK: Setup actions
    
    private func setupActions() {
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        loginTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        authTypeSegment.addTarget(self, action: #selector(authTypeChanged), for: .valueChanged)
        loginButton.addTarget(self, action: #selector(loginButtonTaped), for: .touchUpInside)
        
        forgotPasswordButton.addTarget(self, action: #selector(forgotButtonTaped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTaped), for: .touchUpInside)
        
    }
    
    private func setupTextFieldDelegates() {
        loginTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    //MARK: Validation
    
    private func validateFields() -> Bool {
        let isLoginMode = authTypeSegment.selectedSegmentIndex == 0
        if isLoginMode {
            let loginText = loginTextField.text ?? ""
            let passwordText = passwordTextField.text ?? ""
            return !loginText.isEmpty && !passwordText.isEmpty
        } else {
            let emailText = emailTextField.text ?? ""
            return isValidEmail(emailText)
        }
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    //MARK: Public methods
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            loginButton.isEnabled = false
            loginButton.setTitle("processing".localized, for: .normal)
        } else {
            loginButton.isEnabled = validateFields()
            loginButton.setTitle("loginSign".localized, for: .normal)
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
    func getAuthType() -> Bool {
        return authTypeSegment.selectedSegmentIndex == 0 // true - login, false - mail
    }
    func clearFields() {
        loginTextField.text = nil
        passwordTextField.text = nil
        emailTextField.text = nil
        showError(nil)
        updateLoginButtonState(isEnabled: false)
    }
    func updateLoginButtonState(isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
        loginButton.alpha = loginButton.isEnabled ? 1: 0.4
    }
    
    //MARK: Actions
    
    @objc private func authTypeChanged() {
        let isLoginMode = authTypeSegment.selectedSegmentIndex == 0
        loginTextField.isHidden = !isLoginMode
        emailTextField.isHidden = isLoginMode
        passwordTextField.isHidden = !isLoginMode
        let isEnabled = validateFields()
        updateLoginButtonState(isEnabled: isEnabled)
        onAuthTypeChanged?(isLoginMode)
    }
    
    @objc private func textFieldChanged() {
        let isEnabled = validateFields()
        updateLoginButtonState(isEnabled: isEnabled)
        let isLoginMode = authTypeSegment.selectedSegmentIndex == 0

        if isLoginMode {
            onLoginChanged?(loginTextField.text ?? "")
            onPasswordChanged?(passwordTextField.text ?? "")
        } else {
            onEmailChanged?(emailTextField.text ?? "")
        }
    }
    
    @objc private func loginButtonTaped() {
        onSignInButtonTaped?()
    }
    @objc private func forgotButtonTaped() {
        
        onForgotPasswordTaped?()
    }
    @objc private func registerTaped() {
        
        onRegisterTaped?()
    }
}

//MARK: UITextFieldDelegate

extension AuthorizationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField || textField == emailTextField {
            textField.resignFirstResponder()
            if loginButton.isEnabled {
                onSignInButtonTaped?()
            }
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
        let isEnabled = validateFields()
        updateLoginButtonState(isEnabled: isEnabled)
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        emailTextField.keyboardType = .emailAddress
        showError(nil)
        return true
    }
}
