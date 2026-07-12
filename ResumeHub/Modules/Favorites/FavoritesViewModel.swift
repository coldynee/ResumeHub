//
//  Favorites.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation

final class FavoritesViewModel {
    private let userManager: UserManagerProtocol
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
}
