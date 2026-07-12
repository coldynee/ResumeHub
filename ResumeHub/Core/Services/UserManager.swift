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
        guard let data = userDefaults.data(forKey: userKey) else {
            print("❌ UserManager: нет данных в UserDefaults")
            return nil
        }
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            print("✅ UserManager: загружен пользователь \(user.username)")
            return user
        } catch {
            print("❌ UserManager: не удалось декодировать User — \(error)")
            userDefaults.removeObject(forKey: userKey)
            return nil
        }
    }
    
    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            print("LOGINED ")
            userDefaults.set(data, forKey: userKey)
            print("✅ UserManager сохранён: \(user.username) для uid \(user.id)")
        } else {
            print("❌ UserManager: не удалось сохранить")

        }
    }
    
    func logout() {
        userDefaults.removeObject(forKey: userKey)
    }
    
    
}
