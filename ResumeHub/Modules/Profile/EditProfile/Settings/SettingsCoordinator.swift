//
//  SettingsCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 15.07.2026.
//

import Foundation
import UIKit

protocol SettingsCoordinatorProtocol: AnyObject {
    func dismiss()
}

final class SettingsCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: ProfileCoordinator?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewController = SettingsViewController(userManager: userManager, coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}

extension SettingsCoordinator: SettingsCoordinatorProtocol {
    func dismiss() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
    }
}
