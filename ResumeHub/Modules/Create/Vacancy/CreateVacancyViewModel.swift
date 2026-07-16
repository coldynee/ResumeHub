//
//  VacancyViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class CreateVacancyViewModel {
    private let userManager: UserManagerProtocol
    private let db = Firestore.firestore()
    
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var saveSuccess = false
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func createVacancy(
            companyName: String,
            title: String,
            description: String,
            salary: Int?,
            requirements: [String],
            location: String
    ) {
        guard let user = userManager.currentUser else {
            errorMessage = "userNotFound".localized
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let vacancy = Vacancy(
            userId: user.id,
            companyName: companyName,
            title: title,
            description: description,
            salary: salary,
            requirements: requirements,
            location: location
        )
        
        do {
            try db.collection(FirestoreCollections.vacancies).addDocument(from: vacancy) { [weak self] error in
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

