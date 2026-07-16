//
//  CreateResumeViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class CreateResumeViewModel {
    
    private let userManager: UserManagerProtocol
    private let db = Firestore.firestore()
    
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var saveSuccess = false
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func createResume(title: String, description: String, salary: Int?, experience: String, skills: [String]) {
        guard let user = userManager.currentUser else {
            errorMessage = "userNotFound".localized
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let resume = Resume(
            userId: user.id,
            title: title,
            description: description,
            salary: salary,
            experience: experience,
            skills: skills
        )
        
        do {
            try db.collection(FirestoreCollections.resumes).addDocument(from: resume) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isSaving = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    self?.saveSuccess = true
                }
            }
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
        }
    }
}
