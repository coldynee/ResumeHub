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
    
    private let authService: AuthServiceProtocol
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController,
         authService: AuthServiceProtocol,
         userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.authService = authService
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
            authService: authService,
            userManager: userManager
        )
        addChild(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainScreen() {
        print("12131")
//        let mainCoordinator = MainTabBarCoordinator(
//            navigationController: navigationController,
//            userManager: userManager
//        )
//        addChild(mainCoordinator)
//        mainCoordinator.start()
    }
}
