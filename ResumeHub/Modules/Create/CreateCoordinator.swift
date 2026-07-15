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
    }
    
    func start() {
        guard let user = userManager.currentUser else {
                    // Если пользователь не найден — показываем ошибку
                    let vc = UIViewController()
                    vc.view.backgroundColor = .systemBackground
                    navigationController.setViewControllers([vc], animated: false)
                    return
                }
                
        user.isApplicant ? showResumeCreation() : showVacancyCreation()
    }
    
    private func showResumeCreation() {
        let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground
            vc.title = "createResume".localized
            
            
            let label = UILabel()
            label.text = "📄 Создание резюме\n(скоро)"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
            ])
            
            navigationController.setViewControllers([vc], animated: false)
    }
   
    
    private func showVacancyCreation() {
            // TODO: Открыть экран создания вакансии
            let vc = UIViewController()
            vc.view.backgroundColor = .systemBackground
            vc.title = "createVacancy".localized
            
        
            let label = UILabel()
            label.text = "💼 Создание вакансии\n(скоро)"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 24, weight: .medium)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            vc.view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
            ])
            
            navigationController.setViewControllers([vc], animated: false)
        }
    
}

extension CreateCoordinator: CreateCoordinatorProtocol {
    func dismiss() {
            navigationController.popViewController(animated: true)
            parentCoordinator?.removeChild(self)
        }
}
