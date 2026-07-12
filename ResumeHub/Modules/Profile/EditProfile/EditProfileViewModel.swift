//
//  EditProfileViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 12.07.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class EditProfileViewModel {
    
    private let userManager: UserManagerProtocol
    
    private let db = Firestore.firestore()
    
    @Published var user: User?
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var saveSuccess = false
    @Published var newEmail: String = ""
    @Published var isVerificationRequested = false
    
    private var verificationCode: String?
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    func loadProfile() {
        user = userManager.currentUser
    }
    
    func updateProfile(username: String, firstName: String, lastName: String, isApplicant: Bool) {
        
        print("🔍 updateProfile вызван с username = \(username)")
            print("🔍 Текущий user = \(user?.username ?? "nil")")
        guard let currentUser = user, !username.isEmpty else {
            print("❌ updateProfile: вышли по guard (user = \(user?.username ?? "nil"), username = \(username))")
            return }
        
        isSaving = true
        errorMessage = nil
        print("🔄 updateProfile: пробую обновить \(currentUser.id) на \(username)")

        let userRef = db.collection(FirestoreCollections.users).document(currentUser.id)
        userRef.updateData([
                "firstName": firstName,
                "lastName": lastName,
                "username": username,
                "isApplicant": isApplicant
        ]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                
                if let error = error {
                    print("❌ Ошибка Firestore: \(error.localizedDescription)")
                    
                    self?.errorMessage = error.localizedDescription
                    return
                }
                print("✅ Firestore обновлён: username = \(username)")
                
                let updatedUser = User(
                    id: currentUser.id,
                    email: currentUser.email,
                    username: username,
                    firstName: firstName.isEmpty ? nil : firstName,
                    lastName: lastName.isEmpty ? nil : lastName,
                    isApplicant: isApplicant
                )
                self?.userManager.saveUser(updatedUser)

                self?.user = updatedUser
                self?.saveSuccess = true
            }
        }
    }
    func sendVerificationCode(to email: String) {
        let code = String(format: "%06d", Int.random(in: 0...999999))
        verificationCode = code
        print("code - \(code)")
        
        EmailService.shared.sendVerificationCode(to: email, code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isVerificationRequested = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
            
        }
    }

    func verifyCodeAndSave(_ enteredCode: String, completion: @escaping (Bool) -> Void) {
        guard let code = verificationCode, code == enteredCode else {
            errorMessage = "wrongCode".localized
            completion(false)
            return
        }
        
        // Код верен — сохраняем email
        guard let currentUser = user, !newEmail.isEmpty else {
            completion(false)
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let userRef = db.collection(FirestoreCollections.users).document(currentUser.id)
        userRef.updateData(["email": newEmail]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                let updatedUser = User(
                    id: currentUser.id,
                    email: self?.newEmail ?? currentUser.email,
                    username: currentUser.username,
                    firstName: currentUser.firstName,
                    lastName: currentUser.lastName,
                    isApplicant: currentUser.isApplicant
                )
                
                self?.userManager.saveUser(updatedUser)
                self?.user = updatedUser
                completion(true)
            }
        }
    }
    
    private func updateEmail() {
        guard let currentUser = user, !newEmail.isEmpty else { return }
        
        isSaving = true
        errorMessage = nil
        
        let userRef = db.collection(FirestoreCollections.users).document(currentUser.id)
        userRef.updateData(["email": newEmail]) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                let updatedUser = User(
                    id: currentUser.id,
                    email: self?.newEmail ?? currentUser.email,
                    username: currentUser.username,
                    firstName: currentUser.firstName,
                    lastName: currentUser.lastName,
                    isApplicant: currentUser.isApplicant
                )
                self?.userManager.saveUser(updatedUser)
                self?.user = updatedUser
                self?.saveSuccess = true
            }
        }
    }
}
