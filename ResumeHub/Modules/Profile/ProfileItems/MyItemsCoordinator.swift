//
//  MyItemsCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol MyItemsCoordinatorProtocol: AnyObject {
    func dismiss()
    func showResumeDetail(_ resume: Resume)
    func showVacancyDetail(_ vacancy: Vacancy)
    func showResumeEdit(_ resume: Resume)      // ← добавить
    func showVacancyEdit(_ vacancy: Vacancy)   // ← добавить
}

final class MyItemsCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: ProfileCoordinator?
    weak var detailViewController: ItemDetailViewController?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = MyItemsViewModel(userManager: userManager)
        let viewController = MyItemsViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension MyItemsCoordinator: MyItemsCoordinatorProtocol {
    func dismiss() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
    }
    
    func showResumeDetail(_ resume: Resume) {
        let detailVC = ItemDetailViewController(item: .resume(resume))
        detailVC.parentCoordinator = self
        self.detailViewController = detailVC
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func showVacancyDetail(_ vacancy: Vacancy) {
        let detailVC = ItemDetailViewController(item: .vacancy(vacancy))
        detailVC.parentCoordinator = self
        self.detailViewController = detailVC
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func showResumeEdit(_ resume: Resume) {
        let editCoordinator = ItemEditCoordinator(
            navigationController: navigationController,
            item: .resume(resume),
            userManager: userManager
        )
        editCoordinator.parentCoordinator = self
        editCoordinator.onDismiss = { [weak self] in
            if let myItemsVC = self?.navigationController.viewControllers.first(where: { $0 is MyItemsViewController }) as? MyItemsViewController {
                myItemsVC.viewModel.loadItems()
            }
        
        }
    
        
        addChild(editCoordinator)
        editCoordinator.start()
    }
    
    func showVacancyEdit(_ vacancy: Vacancy) {
        let editCoordinator = ItemEditCoordinator(
            navigationController: navigationController,
            item: .vacancy(vacancy),
            userManager: userManager
        )
        editCoordinator.parentCoordinator = self
        editCoordinator.onDismiss = { [weak self] in
            if let myItemsVC = self?.navigationController.viewControllers.first(where: { $0 is MyItemsViewController }) as? MyItemsViewController {
                myItemsVC.viewModel.loadItems()
            }
        }
        addChild(editCoordinator)
        editCoordinator.start()
    }
}
