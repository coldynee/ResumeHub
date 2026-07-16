//
//  CreateCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 15.07.2026.
//

import Foundation
import UIKit

protocol CreateCoordinatorProtocol: AnyObject {
    func dismiss()
}

class CreateCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: MainTabBarCoordinatorProtocol?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(profileUpdated),
            name: NotificationNames.userProfileUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func start() {
        showAppropriateScreen()
    }
    
    private func showAppropriateScreen() {
        guard let user = userManager.currentUser else {
            let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground
            navigationController.setViewControllers([vc], animated: false)
            return
        }
        
        let viewController: UIViewController
        if user.isApplicant {
            let viewModel = CreateResumeViewModel(userManager: userManager)
            viewController = CreateResumeViewController(viewModel: viewModel, coordinator: self)
        } else {
            let viewModel = CreateVacancyViewModel(userManager: userManager)
            viewController = CreateVacancyViewController(viewModel: viewModel, coordinator: self)
        }
        
        // ✅ Заменяем весь стек на один контроллер — кнопки «Назад» нет
        navigationController.setViewControllers([viewController], animated: false)
    }

    
    @objc private func profileUpdated() {
        showAppropriateScreen()
    }
}

extension CreateCoordinator: CreateCoordinatorProtocol {
    func dismiss() {
            navigationController.popViewController(animated: true)
            parentCoordinator?.removeChild(self)
        }
}
