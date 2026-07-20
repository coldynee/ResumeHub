//
//  FeedViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import Combine
import FirebaseFirestore

struct FeedItem: Identifiable {
    let id: String
    let type: String
    let userId: String
    let title: String
    let description: String
    let salary: Int?
    let createdAt: Date
    let username: String
    let companyName: String?
    let location: String?
    let experience: String?
    let skills: [String]?
}

final class FeedViewModel {
    
    private let userManager: UserManagerProtocol
    private let db = Firestore.firestore()
    
    @Published var items: [FeedItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isApplicant: Bool {
        userManager.currentUser?.isApplicant ?? true
    }
    
    private var listener: ListenerRegistration?
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func loadFeed() {
        isLoading = true
        errorMessage = nil
        print("📱 loadFeed вызван, isApplicant: \(isApplicant)")

        isApplicant ? loadVacancies() : loadResumes()
    }
    
    private func loadVacancies() {
        print("📋 Загружаем вакансии...")

        listener = db.collection(FirestoreCollections.vacancies)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener {
                [weak self] snapshot,
                error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("❌ Ошибка загрузки вакансий: \(error)")

                        self.errorMessage = error.localizedDescription
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        print("⚠️ Нет документов в коллекции vacancies")
                        return
                    }
                    print("📄 Найдено \(documents.count) вакансий")
                    let group = DispatchGroup()
                    var items: [FeedItem] = []
                    
                    for document in documents {
                        group.enter()
                        let data = document.data()
                        
                        let userId = data["userId"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let salary = data["salary"] as? Int
                        let companyName = data["companyName"] as? String
                        let location = data["location"] as? String
                        let timestamp = data["createdAt"] as? Timestamp
                        let createdAt = timestamp?.dateValue() ?? Date()
                        
                        self.db.collection(FirestoreCollections.users).document(userId).getDocument() {
                            userSnapshot,
                            _ in
                            let username = userSnapshot?.data()?["username"] as? String ?? "Unknown"
                            let item = FeedItem(
                                id: document.documentID,
                                type: "vacancy",
                                userId: userId,
                                title: title,
                                description: description,
                                salary: salary,
                                createdAt: createdAt,
                                username: username,
                                companyName: companyName,
                                location: location,
                                experience: nil,
                                skills: nil
                            )
                            items.append(item)
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        let sortedItems = items.sorted { $0.createdAt > $1.createdAt }
                        print("✅ items обновлён: \(sortedItems.count) элементов")
                        print("📝 Первый элемент: \(sortedItems.first?.title ?? "nil")")
                        self.items = sortedItems
                    }
                }
            }
        
    }
    private func loadResumes() {
        print("📄 Загружаем резюме...")
        listener = db.collection(FirestoreCollections.resumes)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("❌ Ошибка загрузки резюме: \(error)")
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ Нет документов в коллекции resumes")
                        return
                    }
                    print("📄 Найдено \(documents.count) резюме")
                    let group = DispatchGroup()
                    var items: [FeedItem] = []
                    
                    for document in documents {
                        group.enter()
                        let data = document.data()
                        
                        let userId = data["userId"] as? String ?? ""
                        let title = data["title"] as? String ?? ""
                        let description = data["description"] as? String ?? ""
                        let salary = data["salary"] as? Int
                        let experience = data["experience"] as? String
                        let skills = data["skills"] as? [String]
                        let timestamp = data["createdAt"] as? Timestamp
                        let createdAt = timestamp?.dateValue() ?? Date()
                        
                        self.db.collection(FirestoreCollections.users).document(userId).getDocument { userSnapshot, _ in
                            let username = userSnapshot?.data()?["username"] as? String ?? "Unknown"
                            
                            let item = FeedItem(
                                id: document.documentID,
                                type: "resume",
                                userId: userId,
                                title: title,
                                description: description,
                                salary: salary,
                                createdAt: createdAt,
                                username: username,
                                companyName: nil,
                                location: nil,
                                experience: experience,
                                skills: skills
                            )
                            items.append(item)
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        self.items = items.sorted { $0.createdAt > $1.createdAt }
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    deinit {
        stopListening()
    }
        
}
