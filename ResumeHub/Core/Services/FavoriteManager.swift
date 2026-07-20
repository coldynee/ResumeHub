//
//  FavoriteManager.swift
//  ResumeHub
//
//  Created by Никита Морозов on 20.07.2026.
//

import Foundation
import Combine
import FirebaseFirestore

enum FavoriteType: String {
    case resume = "resume"
    case vacancy = "vacancy"
}

final class FavoriteManager {
    static let shared = FavoriteManager()
    private init() {}
    
    private let userManager = UserManager()
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private let key = "favorites"
    
    @Published var favorites: [String: Bool] = [:]
    
    func isFavorite(itemId: String) -> Bool {
        return favorites[itemId] ?? false
    }
    
    func toggleFavorite(itemId: String, type: FavoriteType, completion: ((Bool) -> Void)? = nil) {
        guard let userId = userManager.currentUser?.id else {
            completion?(false)
            return
        }
        
        let currentState = isFavorite(itemId: itemId)
        let newState = !currentState
        
        if newState {
            let data: [String: Any] = [
                "itemId": itemId,
                "type": type.rawValue,
                "addedAt": FieldValue.serverTimestamp()
            ]
            
            db.collection("users")
                .document(userId)
                .collection("favorites")
                .document(itemId)
                .setData(data) { [weak self] error in
                    if error == nil {
                        self?.favorites[itemId] = true
                    }
                    completion?(error == nil)
                }
        } else {
            db.collection("users")
                .document(userId)
                .collection("favorites")
                .document(itemId)
                .delete { [weak self] error in
                    if error == nil {
                        self?.favorites[itemId] = false
                    }
                    completion?(error == nil)
                }
        }
        
    }
    
    func loadFavorites(completion: (([FavoriteItem]) -> Void)? = nil) {
        guard let userId = userManager.currentUser?.id else {
            completion?([])
            return
        }
        
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .order(by: "addedAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion?([])
                    return
                }
                
                // Обновляем локальный кэш
                var favDict: [String: Bool] = [:]
                for doc in documents {
                    let itemId = doc.data()["itemId"] as? String ?? ""
                    favDict[itemId] = true
                }
                self?.favorites = favDict
                
                // Загружаем полные данные элементов
                var items: [FavoriteItem] = []
                let group = DispatchGroup()
                
                for document in documents {
                    let data = document.data()
                    let itemId = data["itemId"] as? String ?? ""
                    let type = data["type"] as? String ?? ""
                    
                    group.enter()
                    if type == "resume" {
                        self?.db.collection("resumes").document(itemId).getDocument { snapshot, _ in
                            if let resume = try? snapshot?.data(as: Resume.self) {
                                items.append(.resume(resume))
                            }
                            group.leave()
                        }
                    } else if type == "vacancy" {
                        self?.db.collection("vacancies").document(itemId).getDocument { snapshot, _ in
                            if let vacancy = try? snapshot?.data(as: Vacancy.self) {
                                items.append(.vacancy(vacancy))
                            }
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion?(items)
                }
            }
        
    }
    
    func clear() {
        favorites.removeAll()
    }
    
}

enum FavoriteItem {
    case resume(Resume)
    case vacancy(Vacancy)
    
    var id: String {
        switch self {
        case .resume(let resume): return resume.id ?? ""
        case .vacancy(let vacancy): return vacancy.id ?? ""
        }
    }
    
    var title: String {
        switch self {
        case .resume(let resume): return resume.title
        case .vacancy(let vacancy): return vacancy.title
        }
    }
    
    var type: String {
        switch self {
        case .resume: return "resume"
        case .vacancy: return "vacancy"
        }
    }
}
