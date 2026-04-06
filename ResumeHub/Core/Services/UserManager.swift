//
//  UserManager.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation

protocol UserManagerProtocol {
    var isLoggedIn: Bool { get }
    var currentUser: User? { get }
    func saveUser(_ user: User)
    func logout()
}

final class UserManager: UserManagerProtocol {
    
    private let userDefaults = UserDefaults.standard
    private let userKey = UserDefaultsKeys.currentUser
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    var currentUser: User? {
        guard let data = userDefaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            print("LOGINED ")
            userDefaults.set(data, forKey: userKey)
        }
    }
    
    func logout() {
        userDefaults.removeObject(forKey: userKey)
    }
    
    
}
