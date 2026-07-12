//
//  FeedCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import UIKit

protocol FeedCoordinatorProtocol: AnyObject {
    //feed logic
}

final class FeedCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: MainTabBarCoordinatorProtocol?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController

        self.userManager = userManager
    }
    
    func start() {
        let viewModel = FeedViewModel(userManager: userManager)
        let viewController = FeedViewController(viewModel: viewModel, coordinator: self)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    
    
    
}

extension FeedCoordinator: FeedCoordinatorProtocol {
    // feed logic
}
