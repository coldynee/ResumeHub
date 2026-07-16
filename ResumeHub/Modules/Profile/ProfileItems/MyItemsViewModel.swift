//
//  MyItemsViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class MyItemsViewModel {
    
    private let userManager: UserManagerProtocol
    private let db = Firestore.firestore()
    
    @Published var items: [Any] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isApplicant: Bool {
        return userManager.currentUser?.isApplicant ?? true
    }
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func loadItems() {
        guard let userId = userManager.currentUser?.id else { return }
        
        isLoading = true
        
        if isApplicant {
            loadResumes(for: userId)
        } else {
            loadVacancies(for: userId)
        }
    }
    
    private func loadResumes(for userId: String) {
        db.collection(FirestoreCollections.resumes)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    self?.items = snapshot?.documents.compactMap { document in
                        try? document.data(as: Resume.self)
                    } ?? []
                }
            }
    }
    
    private func loadVacancies(for userId: String) {
        db.collection(FirestoreCollections.vacancies)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    self?.items = snapshot?.documents.compactMap { document in
                        try? document.data(as: Vacancy.self)
                    } ?? []
                }
            }
    }
}
