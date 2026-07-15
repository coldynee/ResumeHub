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
        launchCoordinator.parentCoordinator = self
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
//            let alert = UIAlertController(
//                title: "Success",
//                message: "Logged in successfully!",
//                preferredStyle: .alert
//            )
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            navigationController.present(alert, animated: true)
            
        print("🏠 showMainFlow вызван")

             let mainCoordinator = MainTabBarCoordinator(
                 navigationController: navigationController,
                 userManager: userManager)
        mainCoordinator.parentCoordinator = self
             addChild(mainCoordinator)
             mainCoordinator.start()
    }
    
    //MARK: Public methods
    func didFinishAuth() {
        print("✅ didFinishAuth вызван")

        childCoordinators.removeAll()
        showMainFlow()
    }
    func didLogOut() {
        print("🔄 AppCoordinator.didLogOut() вызван")
            userManager.logout()
            childCoordinators.removeAll()
            
            // Создаём новый navigationController
            let newNav = UINavigationController()
            navigationController = newNav
            
            // ✅ Обновляем window.rootViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                print("✅ Обновляем window.rootViewController")
                window.rootViewController = newNav
                window.makeKeyAndVisible()
            } else {
                print("❌ Не удалось найти window")
            }
            
            showAuthFlow()
    }
    
}
