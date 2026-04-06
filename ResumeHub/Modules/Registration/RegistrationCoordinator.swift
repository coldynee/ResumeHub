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
}

final class RegistrationCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: AppCoordinator?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = RegistrationViewModel(userManager: userManager)
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
    

}
