//
//  FavoritesCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import UIKit

protocol FavoritesCoordinatorProtocol: AnyObject {
    func showResumeDetail(_ resume: Resume)
    func showVacancyDetail(_ vacancy: Vacancy)
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
    func showResumeDetail(_ resume: Resume) {
        let detailVC = ItemDetailViewController(item: .resume(resume), source: .favorites)
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func showVacancyDetail(_ vacancy: Vacancy) {
        let detailVC = ItemDetailViewController(item: .vacancy(vacancy), source: .favorites)
        navigationController.pushViewController(detailVC, animated: true)
    }

}
