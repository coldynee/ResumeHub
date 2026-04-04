//
//  RegistrationCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation
import UIKit

protocol RegistrationCoordinatorProtocol: AnyObject {
    func showMainScreen()
    func showAuthorization()
    func showCodeVerification(email: String)
}

final class RegistrationCoordinator: Coordinator {
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
        let viewModel = RegistrationViewModel(authService: authService, userManager: userManager)
        let viewController = RegistrationViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}

//MARK: RegistrationCoordinatorProtocol

extension RegistrationCoordinator: RegistrationCoordinatorProtocol {
    func showMainScreen() {
        parentCoordinator?.didFinishAuth()
    }
    
    func showAuthorization() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
    }
    
    func showCodeVerification(email: String) {
        let alert = UIAlertController(title: "123", message: "go to code", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default))
        navigationController.present(alert, animated: true)
    }
}
