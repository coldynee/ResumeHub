//
//  AppCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    //MARK: Dependencies
    private let userManager: UserManagerProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        self.userManager = UserManager()
    }
    
    //MARK: Start
    func start() {
        let launchCoordinator = LaunchCoordinator(
                    navigationController: navigationController,
                    userManager: userManager
                )
                addChild(launchCoordinator)
                launchCoordinator.start()
        
    }
    
    //MARK: Flow managment
    private func showAuthFlow() {
        let authCoordinator = AuthorizationCoordinator(navigationController: navigationController,
            userManager: userManager)
        authCoordinator.parentCoordinator = self
        addChild(authCoordinator)
        authCoordinator.start()
    }
    private func showMainFlow() {
        // Временно показываем алерт вместо главного экрана
            let alert = UIAlertController(
                title: "Success",
                message: "Logged in successfully!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            navigationController.present(alert, animated: true)
            
            // Позже раскомментируешь:
            // let mainCoordinator = MainTabBarCoordinator(
            //     navigationController: navigationController,
            //     userManager: userManager)
            // addChild(mainCoordinator)
            // mainCoordinator.start()
    }
    
    //MARK: Public methods
    func didFinishAuth() {
        childCoordinators.removeAll()
        showMainFlow()
    }
    func didLogOut() {
        //userManager.logout()
        childCoordinators.removeAll()
        navigationController = UINavigationController()
        showAuthFlow()
    }
    
}
