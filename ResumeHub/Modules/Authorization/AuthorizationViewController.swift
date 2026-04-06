//
//  AuthorizationViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 27.03.2026.
//

import UIKit
import Combine


final class AuthorizationViewController: UIViewController {

    //MARK: Properties
    private let mainView = AuthorizationView()
    private let viewModel: AuthorizationViewModel
    private let coordinator: AuthorizationCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AuthorizationViewModel, coordinator: AuthorizationCoordinatorProtocol) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        setupActions()
        setupNavigation()
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.mainView.showLoading(isLoading)
            }
            .store(in: &cancellables)
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.mainView.showError(error)
            }
            .store(in: &cancellables)
        viewModel.$loginSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success {
                    self?.coordinator.showMainScreen()
                }
            }
            .store(in: &cancellables)
        viewModel.$emailSent
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] sent in
                        if sent {
                            self?.showCodeInputAlert()
                        }
                    }
                    .store(in: &cancellables)
        viewModel.$isFormValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.mainView.updateLoginButtonState(isEnabled: isValid)
            }
            .store(in: &cancellables)
    }

    //MARK: Setup actions
    private func setupActions() {
        mainView.onAuthTypeChanged = { [weak self] isLoginMode in
            self?.viewModel.updateAuthMode(isLoginMode: isLoginMode)
        }
        mainView.onLoginChanged = { [weak self] username in
            self?.viewModel.updateUsername(username)
        }
        mainView.onEmailChanged = { [weak self] email in
            self?.viewModel.updateEmail(email)
        }
        mainView.onPasswordChanged = { [weak self] password in
            self?.viewModel.updatePassword(password)
        }
        
        mainView.onSignInButtonTaped = { [weak self] in
            self?.handleSignIn()
        }
        
        mainView.onForgotPasswordTaped = { [weak self] in
            self?.coordinator.showForgotPassword(textFromTextField: self?.viewModel.username ?? "")
        }
        
        mainView.onRegisterTaped = { [weak self] in
            self?.coordinator.showRegistration()
        }
        
    }
    
    //MARK: Navigation setup
    
    private func handleSignIn() {
        
        let isLoginMode = mainView.getAuthType()
        
        if isLoginMode {
            let username = mainView.getLogin()
            let password = mainView.getPassword()
            
            guard !username.isEmpty, !password.isEmpty else {
                mainView.showError("fillFields".localized)
                return
            }
            
            viewModel.username = username
            viewModel.password = password
            viewModel.loginWithPassword()
            
        } else {
            let email = mainView.getEmail()
            guard mainView.isValidEmail(email) else {
                mainView.showError("invalidEmail".localized)
                return
            }
            viewModel.email = email
            viewModel.sendCodeToEmail()
        }
        
    }
    
    private func setupNavigation() {
        title = nil
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
    }
}

//MARK: Extensions

extension AuthorizationViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    private func showCodeInputAlert() {
        let alert = UIAlertController(
            title: "verifyCode".localized,
            message: "codeSended".localized + " \(viewModel.email)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "emailCode".localized
            textField.keyboardType = .numberPad
            textField.font = .systemFont(ofSize: 20, weight: .medium)
            textField.textAlignment = .center
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "confirm".localized, style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text, !code.isEmpty else {
                self?.mainView.showError("emailCode".localized)
                return
            }
            self?.viewModel.verifyCodeAndLogin(code)
        })
        
        alert.addAction(UIAlertAction(title: "resentCode".localized, style: .default) { [weak self] _ in
            self?.viewModel.sendCodeToEmail()
        })
        
        present(alert, animated: true)
    }

}
