//
//  RegistrationViewController.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import UIKit
import Combine

final class RegistrationViewController: UIViewController {
    
    //MARK: Properties
    private let mainView = RegistrationView()
    private let viewModel: RegistrationViewModel
    private let coordinator: RegistrationCoordinatorProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: RegistrationViewModel, coordinator: RegistrationCoordinatorProtocol) {
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(systemItem: .close)

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
        viewModel.$registerSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success { self?.coordinator.showMainScreen() }
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
                    self?.mainView.updateRegisterButtonState()
                }
                .store(in: &cancellables)
        viewModel.$password
                .combineLatest(viewModel.$confirmPassword)
                .sink { [weak self] password, confirm in
                    guard let self = self else { return }
                    
                    if !confirm.isEmpty && password != confirm {
                        self.mainView.showError("passwordsDoNotMatch".localized)
                    } else if !password.isEmpty && !self.viewModel.isPasswordValid(password) {
                        self.mainView.showError("passwordTooWeak".localized)
                    } else {
                        self.mainView.showError(nil)
                    }
                }
                .store(in: &cancellables)
    }
    
    //MARK: Setup actions
    
    private func setupActions() {
        mainView.onEmailChanged = { [weak self] email in
            self?.viewModel.email = email
        }
        mainView.onLoginChanged = { [weak self] login in
            self?.viewModel.username = login
        }
        mainView.onPasswordChanged = { [weak self] password in
            self?.viewModel.password = password
        }
        mainView.onConfirmPasswordChanged = { [weak self] confirmPassword in
            if let password = self?.viewModel.password, password != confirmPassword {
                            self?.mainView.showError("passwordsDoNotMatch".localized)
                        } else {
                            self?.mainView.showError(nil)
                        }
        }
        mainView.onRegisterTaped = { [weak self] in
            self?.handleRegister()
        }
        mainView.onHaveAccountTaped = {[weak self] in
            self?.coordinator.showAuthorization()
        }
    }
    
    //MARK: Navigation setup
    
    private func handleRegister() {
        let username = mainView.getLogin()
        let email = mainView.getEmail()
        let password = mainView.getPassword()
        let confirmPassword = mainView.getConfirmPassword()
        
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            mainView.showError("fillFields".localized)
            return
        }
        guard viewModel.isLoginValid(username) else {
                mainView.showError("invalidLogin".localized)
                return
            }
            
            guard viewModel.isEmailValid(email) else {
                mainView.showError("invalidEmail".localized)
                return
            }
            
            guard viewModel.isPasswordValid(password) else {
                mainView.showError("passwordTooWeak".localized)
                return
            }
            
            guard password == confirmPassword else {
                mainView.showError("passwordsDoNotMatch".localized)
                return
            }
        
        viewModel.username = username
        viewModel.email = email
        viewModel.password = password
        viewModel.register()
    }
    
    private func setupNavigation() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTaped))
        backButton.tintColor = UIColor.primaryBlueContent
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTaped() {
        coordinator.showAuthorization()
    }
}

//MARK: Extensions

extension RegistrationViewController {
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
        present(alert, animated: true)
    }
    private func showCodeInputAlert() {
        let alert = UIAlertController(title: "emailConfirm".localized, message: "\("codeSended".localized) \(viewModel.email) \("inputCodeToRegister".localized)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "emailCode".localized
            textField.keyboardType = .numberPad
            textField.font = .systemFont(ofSize: 24, weight: .medium)
            textField.textAlignment = .center
        }
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "confirm".localized, style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text, !code.isEmpty else {
                self?.mainView.showError("inputCode".localized)
                return
            }
            self?.viewModel.verifyCode(code)
        })
        
        alert.addAction(UIAlertAction(title: "resentCode".localized, style: .default) { [weak self] _ in
            self?.viewModel.resendCode()
        })
        present(alert, animated: true)
    }
}
