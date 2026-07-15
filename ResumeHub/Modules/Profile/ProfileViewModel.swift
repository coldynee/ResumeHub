//
//  ProfileViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import Combine

final class ProfileViewModel {
    
    private let userManager: UserManagerProtocol
    
    @Published var user: User?
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func loadProfile() {
        user = userManager.currentUser
        print("👤 ProfileViewModel загружен: \(user?.username ?? "nil"), avatarURL: \(user?.avatarURL ?? "nil")")
    }
    
    func logout() {
        userManager.logout()
    }
}
