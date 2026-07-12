//
//  EditProfileCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import UIKit

protocol EditProfileCoordinatorProtocol: AnyObject {
    func dismiss()
}

class EditProfileCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: ProfileCoordinator?
    
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    func start() {
        let viewModel = EditProfileViewModel(userManager: userManager)
        let viewContorller = EditProfileViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(viewContorller, animated: true)
    }
    
    
}

extension EditProfileCoordinator: EditProfileCoordinatorProtocol {
    func dismiss() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
    }
}
