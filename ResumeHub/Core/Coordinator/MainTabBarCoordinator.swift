//
//  MainTabBarCoordinator.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import UIKit

protocol MainTabBarCoordinatorProtocol: Coordinator {
    func didLogout()
    func removeChild(_ coordinator: Coordinator)
}

class MainTabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    weak var parentCoordinator: AppCoordinator?
    
    private let userManager: UserManagerProtocol
    private var tabBarController = UITabBarController()
    
    func start() {
        setupTabBarController()
        setupTabs()
        navigationController.setViewControllers([tabBarController], animated: true)
    }
    
    init(navigationController: UINavigationController, userManager: UserManagerProtocol) {
        self.navigationController = navigationController
        self.userManager = userManager
    }
    
    private func setupTabBarController() {
        tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = .primaryBlueContent
        tabBarController.tabBar.backgroundColor = .primaryBackground
    }
    
    private func setupTabs() {
        let feedCoordinator = FeedCoordinator(navigationController: UINavigationController(), userManager: userManager)
        feedCoordinator.parentCoordinator = self
        addChild(feedCoordinator)
        feedCoordinator.start()
        feedCoordinator.navigationController.tabBarItem = UITabBarItem(title: "feed".localized, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let favoritesCoordinator = FavoritesCoordinator(navigationController: UINavigationController(), userManager: userManager)
        favoritesCoordinator.parentCoordinator = self
        addChild(favoritesCoordinator)
        favoritesCoordinator.start()
        favoritesCoordinator.navigationController.tabBarItem = UITabBarItem(title: "favorites".localized, image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))
        
        let createCoordinator = CreateCoordinator(navigationController: UINavigationController(), userManager: userManager)
        createCoordinator.parentCoordinator = self
        addChild(createCoordinator)
        createCoordinator.start()
        createCoordinator.navigationController.tabBarItem = UITabBarItem(title: "create".localized, image: UIImage(systemName: "plus.circle"), selectedImage: UIImage(systemName: "plus.circle.fill"))
        
        let chatCoordinator = ChatCoordinator(navigationController: UINavigationController(), userManager: userManager)
        chatCoordinator.parentCoordinator = self
        addChild(chatCoordinator)
        chatCoordinator.start()
        chatCoordinator.navigationController.tabBarItem = UITabBarItem(title: "chat".localized, image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message.fill"))
        
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController(), userManager: userManager)
        profileCoordinator.parentCoordinator = self
        addChild(profileCoordinator)
        profileCoordinator.start()
        profileCoordinator.navigationController.tabBarItem = UITabBarItem(title: "profile".localized, image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        tabBarController.viewControllers = [feedCoordinator.navigationController, favoritesCoordinator.navigationController, createCoordinator.navigationController, chatCoordinator.navigationController, profileCoordinator.navigationController]
    }
}

extension MainTabBarCoordinator: MainTabBarCoordinatorProtocol {
    func didLogout() {
        print("🔄 MainTabBarCoordinator.didLogout() вызван")
        childCoordinators.removeAll()
        parentCoordinator?.didLogOut()
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}
