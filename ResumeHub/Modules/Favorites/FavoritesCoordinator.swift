//
//  FavoritesCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import UIKit

protocol FavoritesCoordinatorProtocol: AnyObject {
    // fav logic
}

final class FavoritesCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: MainTabBarCoordinatorProtocol?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = FavoritesViewModel(userManager: userManager)
        let viewController = FavoritesViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    
}

extension FavoritesCoordinator: FavoritesCoordinatorProtocol {
    // fav logic
}
