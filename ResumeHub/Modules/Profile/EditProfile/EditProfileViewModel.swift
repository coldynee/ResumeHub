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
    @Published var selectedImage: UIImage?
    @Published var isAvatarChanged = false
    @Published var newPassword: String?

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

        if let image = selectedImage, isAvatarChanged {
            print("📸 Загружаем новую аватарку...")

            AvatarService.shared.uploadAvatarToImageBan(image) { [weak self] avatarURL in
                DispatchQueue.main.async {
                    guard let self = self else {
                                        print("❌ self = nil, прерываем")
                                        return
                                    }
                    print("📸 Получена ссылка в ViewModel: \(avatarURL ?? "nil")")

                    if let url = avatarURL {
                        print("📸 Вызываю saveProfileData с url = \(url)")
                        print("👤 user перед saveProfileData: \(self.user?.username ?? "nil")")
                        self.saveProfileData(
                            username: username,
                            firstName: firstName,
                            lastName: lastName,
                            isApplicant: isApplicant,
                            avatarURL: url
                            )
                    } else {
                        print("❌ avatarURL = nil")

                        self.isSaving = false
                        self.errorMessage = "Не удалось загрузить аватарку"
                        }
                    }
                }
        } else {
            print("📸 Аватарка не менялась")

                // Если аватарка не менялась — просто сохраняем остальное
                saveProfileData(
                    username: username,
                    firstName: firstName,
                    lastName: lastName,
                    isApplicant: isApplicant,
                    avatarURL: currentUser.avatarURL
                )
            }
    }
    
    private func saveProfileData(username: String, firstName: String, lastName: String, isApplicant: Bool, avatarURL: String?) {
        print("👤 user в saveProfileData: \(user?.username ?? "nil")")

        print("📸 saveProfileData вызван")
            print("📸 avatarURL: \(avatarURL ?? "nil")")
        guard let currentUser = user else {
            print("❌ Нет currentUser")
            return
        }
        
        print("🆔 currentUser.id = \(currentUser.id)")

        print("📸 Сохраняем avatarURL: \(avatarURL ?? "nil")")

        let userRef = db.collection(FirestoreCollections.users).document(currentUser.id)
        userRef.updateData([
                "firstName": firstName,
                "lastName": lastName,
                "username": username,
                "isApplicant": isApplicant,
                "avatarURL": avatarURL ?? ""
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
                    isApplicant: isApplicant,
                    avatarURL: avatarURL
                )
                print("👤 Сохраняем в UserManager: \(updatedUser.username), avatarURL: \(updatedUser.avatarURL ?? "nil")")

                self?.userManager.saveUser(updatedUser)
                self?.user = updatedUser
                self?.saveSuccess = true
                print("✅ Пользователь сохранён в UserManager с avatarURL = \(avatarURL ?? "nil")")

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
        
        guard let currentUser = user else {
            completion(false)
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        var updateData: [String: Any] = [:]
        
        if !newEmail.isEmpty {
            updateData["email"] = newEmail
        }
        
        if let newPassword = newPassword, !newPassword.isEmpty {
            updateData["password"] = newPassword
        }
        
        guard !updateData.isEmpty else {
            isSaving = false
            completion(true)
            return
        }
        
        let userRef = db.collection(FirestoreCollections.users).document(currentUser.id)
        userRef.updateData(updateData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSaving = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                // ✅ Сохраняем ВСЕ данные
                let updatedUser = User(
                    id: currentUser.id,
                    email: (self?.newEmail.isEmpty ?? true) ? currentUser.email : (self?.newEmail ?? currentUser.email),
                    username: currentUser.username,
                    firstName: currentUser.firstName,
                    lastName: currentUser.lastName,
                    isApplicant: currentUser.isApplicant,
                    avatarURL: currentUser.avatarURL
                )
                
                print("📸 Сохраняем в UserManager: \(updatedUser.username), avatarURL: \(updatedUser.avatarURL ?? "nil")")
                self?.userManager.saveUser(updatedUser)
                self?.user = updatedUser
                self?.saveSuccess = true
                self?.newPassword = nil
                self?.newEmail = ""
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
                    isApplicant: currentUser.isApplicant,
                    avatarURL: currentUser.avatarURL
                )
                self?.userManager.saveUser(updatedUser)
                self?.user = updatedUser
                self?.saveSuccess = true
            }
        }
    }
}
