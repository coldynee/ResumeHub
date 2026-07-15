//
//  ProfileCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import UIKit

protocol ProfileCoordinatorProtocol: AnyObject {
    func didLogout()
    func showEditProfile()
    func showSettings()
}

final class ProfileCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: MainTabBarCoordinatorProtocol?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = ProfileViewModel(userManager: userManager)
        let viewController = ProfileViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    
}

extension ProfileCoordinator: ProfileCoordinatorProtocol {
    func showEditProfile() {
        let editCoordinator = EditProfileCoordinator(
                navigationController: navigationController,
                userManager: userManager
            )
            editCoordinator.parentCoordinator = self
            editCoordinator.onDismiss = { [weak self] in
                // Принудительно обновляем профиль
                if let profileVC = self?.navigationController.viewControllers.first as? ProfileViewController {
                    profileVC.viewModel.loadProfile()
                }
            }
            addChild(editCoordinator)
            editCoordinator.start()
    }
    
    func didLogout() {
        print("🔄 ProfileCoordinator.didLogout() вызван")
            print("parentCoordinator = \(parentCoordinator != nil ? "✅ есть" : "❌ nil")")
        childCoordinators.removeAll()
        parentCoordinator?.didLogout()
    }
    
    func showSettings() {
        let settingsCoordinator = SettingsCoordinator(
            navigationController: navigationController,
            userManager: userManager
        )
        settingsCoordinator.parentCoordinator = self
        addChild(settingsCoordinator)
        settingsCoordinator.start()
    }
    
}
