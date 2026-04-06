//
//  RegistrationViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation
import Combine
import FirebaseFirestore

final class RegistrationViewModel {
    
    //MARK: Dependecies
    private let userManager: UserManagerProtocol
    private var generatedCode: String?
    private var codeExpirationDate: Date?
    private let db = Firestore.firestore()
    
    
    //MARK: State
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registerSuccess = false
    @Published var emailSent = false
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isFormValid: Bool = false
    //MARK: Init
    
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    
    //MARK: Public methods
    
    private func updateFormValidity() {
        isFormValid = !username.isEmpty && isLoginValid(username)
            && !email.isEmpty && isEmailValid(email)
            && !password.isEmpty && isPasswordValid(password) && password == confirmPassword
        
    }
    
    func updateUsername(_ value: String) {
        username = value
        updateFormValidity()
    }

    func updateEmail(_ value: String) {
        email = value
        updateFormValidity()
    }

    func updatePassword(_ value: String) {
        password = value
        updateFormValidity()
    }

    func updateConfirmPassword(_ value: String) {
        confirmPassword = value
        updateFormValidity()
    }
    
    func register() {
        isLoading = true
        errorMessage = nil
        
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            isLoading = false
            errorMessage = "fillAllFields".localized
            return
        }
        
        // Проверяем, не занят ли логин или email
        checkUserExists()
    }
    
    func sendCodeToEmail() {
        isLoading = true
        
        let code = String(format: "%06d", Int.random(in: 0...999999))
        generatedCode = code
        codeExpirationDate = Date().addingTimeInterval(15 * 60)
        
        print("📧 Код: \(code) на \(email)")
        
        EmailService.shared.sendVerificationCode(to: email, code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.emailSent = true
                case .failure(let error):
                    self?.errorMessage = "Ошибка отправки: \(error.localizedDescription)"
                }
            }
        }
    }
    func verifyCode(_ enteredCode: String) {
        isLoading = true
        errorMessage = nil
        
        guard let generatedCode = generatedCode,
              let expirationDate = codeExpirationDate else {
            isLoading = false
            errorMessage = "codeNotSent".localized
            return
        }
        
        guard Date() < expirationDate else {
            isLoading = false
            errorMessage = "codeExpired".localized
            return
        }
        
        guard enteredCode == generatedCode else {
            isLoading = false
            errorMessage = "wrongCode".localized
            return
        }
        
        saveUserToFirestore()
    }
    // RegistrationViewModel.swift

    private func saveUserToFirestore() {
        let userId = UUID().uuidString
        let userData: [String: Any] = [
            "uid": userId,
            "username": username,
            "email": email,
            "password": password,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection(FirestoreCollections.users).document(userId).setData(userData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // ✅ userLogins НЕ НУЖЕН — просто сохраняем пользователя
                let user = User(id: userId, email: self?.email ?? "", username: self?.username ?? "")
                self?.userManager.saveUser(user)
                self?.registerSuccess = true
            }
        }
    }
    func resendCode() {
        sendCodeToEmail()
    }
    // MARK: - Check User Exists
    private func checkUserExists() {
        isLoading = true
        errorMessage = nil
        
        let usersRef = db.collection(FirestoreCollections.users)
        
        // Проверяем логин
        usersRef.whereField("username", isEqualTo: username).getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                self?.isLoading = false
                self?.errorMessage = "Логин уже занят"
                return
            }
            
            // Проверяем email
            usersRef.whereField("email", isEqualTo: self?.email ?? "").getDocuments { snapshot, error in
                if let snapshot = snapshot, !snapshot.isEmpty {
                    self?.isLoading = false
                    self?.errorMessage = "Email уже зарегистрирован"
                    return
                }
                
                // Всё свободно — отправляем код
                self?.sendCodeToEmail()
            }
        }
    }
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "[A-Z0-9a-z!_-]{8,}"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

    func isLoginValid(_ login: String) -> Bool {
        let loginRegex = "[A-Z0-9a-z]{3,20}"
        let loginPredicate = NSPredicate(format: "SELF MATCHES %@", loginRegex)
        return loginPredicate.evaluate(with: login)
    }

    func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
