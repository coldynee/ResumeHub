//
//  ItemEditCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import UIKit

protocol ItemEditCoordinatorProtocol: AnyObject {
    func dismiss()
}

final class ItemEditCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: MyItemsCoordinator?
    
    private let item: EditItemType
    private let userManager: UserManagerProtocol
    
    var onDismiss: (() -> Void)?
    
    init(navigationController: UINavigationController,
         item: EditItemType,
         userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.item = item
        self.userManager = userManager
    }
    
    func start() {
        let viewController = ItemEditViewController(item: item, coordinator: self, userManager: userManager)
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension ItemEditCoordinator: ItemEditCoordinatorProtocol {
    func dismiss() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.removeChild(self)
        onDismiss?()
    }
}
