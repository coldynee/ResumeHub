//
//  AuthorizationCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol AuthorizationCoordinatorProtocol: AnyObject {
    func showMainScreen()
    func showRegistration()
    func showForgotPassword(textFromTextField: String)
}

final class AuthorizationCoordinator: Coordinator {
    
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: AppCoordinator?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = AuthorizationViewModel(
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
            userManager: userManager
        )
        addChild(registrationCoordinator)
        registrationCoordinator.start()
    }
    
    func showForgotPassword(textFromTextField: String) {
        let alert = UIAlertController(
            title: "forgotPassword".localized,
            message: "inputLogin".localized,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "login".localized
            textField.text = textFromTextField
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        let sendAction = UIAlertAction(title: "send".localized, style: .default) { [weak self] _ in
            guard let loginName = alert.textFields?.first?.text, !loginName.isEmpty else {
                self?.showErrorAlert(message: "inputLogin".localized)
                return
            }
            self?.sendPasswordReset(loginName: loginName)
        }
        alert.addAction(sendAction)
        
        navigationController.present(alert, animated: true)
        
    }
    
    func sendPasswordReset(loginName: String) {
        let db = Firestore.firestore()
        
        db.collection(FirestoreCollections.users).whereField("username", isEqualTo: loginName).getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.showErrorAlert(message: error.localizedDescription)
                return
            }
            guard let document = snapshot?.documents.first, let email = document.data()["email"] as? String else {
                self?.showErrorAlert(message: "userNotFound".localized)
                return
            }
            let userId = document.documentID
            let newPassword = self?.generateRandomPassword() ?? "12345678"
            
            db.collection(FirestoreCollections.users).document(userId).updateData([
                "password": newPassword
            ]) { error in
                if let error = error {
                    self?.showErrorAlert(message: error.localizedDescription)
                    return
                }
                self?.sendNewPasswordToEmail(email: email, newPassword: newPassword)
            }
            
        }
    }
    private func generateRandomPassword() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<10).map { _ in letters.randomElement()! })
    }
    
    private func sendNewPasswordToEmail(email: String, newPassword: String) {
        
        // Отправляем письмо через EmailService
        EmailService.shared.sendCustomEmail(to: email, newPassword: newPassword) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showSuccessAlert(email: email)
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }

    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "error".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    func showSuccessAlert(email: String) {
        let alert = UIAlertController(title: "success".localized, message: String(format: "resetPasswordSent".localized, email), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alert, animated: true)
    }
    
}
