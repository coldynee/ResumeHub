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
    private var cancellabels = Set<AnyCancellable>()
    
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
            .store(in: &cancellabels)
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.mainView.showError(error)
            }
            .store(in: &cancellabels)
        viewModel.$loginSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success {
                    self?.coordinator.showMainScreen()
                }
            }
            .store(in: &cancellabels)
    }

    //MARK: Setup actions
    private func setupActions() {
        mainView.onAuthTypeChanged = { [weak self] isLoginMode in
            self?.viewModel.updateAuthMode(isLoginMode: isLoginMode)
        }
        mainView.onLoginChanged = { [weak self] username in
            self?.viewModel.username = username
        }
        mainView.onMailChanged = { [weak self] mail in
            self?.viewModel.mail = mail
        }
        mainView.onPasswordChanged = { [weak self] password in
            self?.viewModel.password = password
        }
        
        mainView.onSignInButtonTaped = { [weak self] in
            self?.handleSignIn()
        }
        
        mainView.onForgotPasswordTaped = { [weak self] in
            self?.coordinator.showForgotPassword()
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
            viewModel.login()
            
        } else {
            let mail = mainView.getMail()
            guard mainView.isValidEmail(mail) else {
                mainView.showError("invalidMail".localized)
                return
            }
            viewModel.mail = mail
            viewModel.sendCodeToMail()
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
}
