//
//  Favorites.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import Combine

final class FavoritesViewModel {
    private let userManager: UserManagerProtocol
    
    @Published var items: [FavoriteItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func loadFavorites() {
        guard userManager.currentUser != nil else {
            errorMessage = "userNotFound".localized
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        FavoriteManager.shared.loadFavorites { [weak self] items in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.items = items
            }
        }
    }
}
