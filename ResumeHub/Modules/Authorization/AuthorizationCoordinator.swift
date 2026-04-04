//
//  AuthorizationCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation
import UIKit

protocol AuthorizationCoordinatorProtocol: AnyObject {
    func showMainScreen()
    func showRegistration()
    func showForgotPassword()
    func showCodeVerification(email: String)
}

final class AuthorizationCoordinator: Coordinator {
    
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: AppCoordinator?
    
    private let authService: AuthServiceProtocol
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, authService: AuthServiceProtocol, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.authService = authService
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = AuthorizationViewModel(
            authService: authService,
            userManager: userManager
        )
        let viewController = AuthorizationViewController(
            viewModel: viewModel,
            coordinator: self
        )
        navigationController.setViewControllers([viewController], animated: false)
        
    }
}

//MARK: AuthorizationCoordinatorProtocol

extension AuthorizationCoordinator: AuthorizationCoordinatorProtocol {
    func showMainScreen() {
        parentCoordinator?.didFinishAuth()
    }
    
    func showRegistration() {
    let registrationCoordinator = RegistrationCoordinator(
        navigationController: navigationController,
        authService: authService,
        userManager: userManager
        )
    addChild(registrationCoordinator)
    registrationCoordinator.start()
    }
    
    func showForgotPassword() {
        let alert = UIAlertController(
            title: "🔐 Forgot Password",
            message: "Enter your email to receive reset instructions",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "email".localized
            textField.keyboardType = .emailAddress
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            if let email = alert.textFields?.first?.text, !email.isEmpty {
                let successAlert = UIAlertController(
                    title: "Email Sent",
                    message: "Reset link sent to \(email)",
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.navigationController.present(successAlert, animated: true)
            }
        })
        
        navigationController.present(alert, animated: true)
        
        //        let forgotCoordinator = ForgotPasswordCoordinator(
        //            navigationController: navigationController,
        //            authService: authService
        //        )
        //        addChild(forgotCoordinator)
        //        forgotCoordinator.start()
    }
    
    func showCodeVerification(email: String) {
        let alert = UIAlertController(
            title: "Verification",
            message: "Enter the code sent to \(email)",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "code".localized
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Verify", style: .default) { _ in
            if let code = alert.textFields?.first?.text, !code.isEmpty {
                let successAlert = UIAlertController(
                    title: "Success",
                    message: "Code verified!",
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.navigationController.present(successAlert, animated: true)
            }
        })
        
        navigationController.present(alert, animated: true)
    }
    
    
    //        let codeVerficationCoordinator = CodeVerificationCoordinator(
    //            navigationController = navigationController,
    //            authService: authService,
    //            email: email
    //        )
    //        addChild(codeVerficationCoordinator)
    //        codeVerficationCoordinator.start()

    
    
    
}
