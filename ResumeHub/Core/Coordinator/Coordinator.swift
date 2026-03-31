//
//  Coordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator}
    }
}
