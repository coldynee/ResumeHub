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
    weak var parentCoordinator: AppCoordinator?
    
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
        print("🔍 showAuthScreen: parentCoordinator = \(parentCoordinator != nil ? "✅ есть" : "❌ nil")")
        let authCoordinator = AuthorizationCoordinator(
            navigationController: navigationController,
            userManager: userManager
        )
        authCoordinator.parentCoordinator = self.parentCoordinator
        print("🔍 authCoordinator.parentCoordinator = \(authCoordinator.parentCoordinator != nil ? "✅ есть" : "❌ nil")")
        addChild(authCoordinator)
        authCoordinator.start()
    }
    
    private func showMainScreen() {
        print("logged from user defaults")
//        let authCoordinator = AuthorizationCoordinator(
//            navigationController: navigationController,
//            userManager: userManager
//        )
//        addChild(authCoordinator)
//        authCoordinator.start()
        let mainCoordinator = MainTabBarCoordinator(
            navigationController: navigationController,
            userManager: userManager
        )
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
    
}
