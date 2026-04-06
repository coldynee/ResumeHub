//
//  LaunchCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import UIKit

protocol LaunchCoordinatorProtocol: AnyObject {
    func showAuthorization()
}

final class LaunchCoordinator: Coordinator, LaunchCoordinatorProtocol {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController,
         userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewController = LaunchViewController(coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showAuthorization() {
        // Проверяем, авторизован ли пользователь
        if userManager.isLoggedIn {
            showMainScreen()
        } else {
            showAuthScreen()
        }
    }
    
    private func showAuthScreen() {
        let authCoordinator = AuthorizationCoordinator(
            navigationController: navigationController,
            userManager: userManager
        )
        addChild(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainScreen() {
        print("logged from user defaults")
        let authCoordinator = AuthorizationCoordinator(
            navigationController: navigationController,
            userManager: userManager
        )
        addChild(authCoordinator)
        authCoordinator.start()
//        let mainCoordinator = MainTabBarCoordinator(
//            navigationController: navigationController,
//            userManager: userManager
//        )
//        addChild(mainCoordinator)
//        mainCoordinator.start()
    }
    
}
