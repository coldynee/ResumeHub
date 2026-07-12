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
        let editCoordinator = EditProfileCoordinator(navigationController: navigationController, userManager: userManager)
        addChild(editCoordinator)
        editCoordinator.start()
    }
    
    func didLogout() {
        parentCoordinator?.didLogout()
    }
}
