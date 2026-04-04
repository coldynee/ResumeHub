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
    private var cancellabels = Set<AnyCancellable>()
    
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
            .store(in: &cancellabels)
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.mainView.showError(error)
            }
            .store(in: &cancellabels)
        viewModel.$registerSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] success in
                if success { self?.coordinator.showMainScreen() }
            }
            .store(in: &cancellabels)
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
        mainView.onConfirmPasswordChanged = { [weak self] password in
            
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
}
