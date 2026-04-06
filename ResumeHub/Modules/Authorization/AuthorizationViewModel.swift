//
//  AuthorizationViewModel.swift
//  ResumeHub
//

import Foundation
import Combine
import FirebaseFirestore

final class AuthorizationViewModel {
    
    private let db = Firestore.firestore()
    private let userManager: UserManagerProtocol
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoginMode = true
    @Published var loginSuccess = false
    @Published var codeSent = false
    @Published var emailSent = false
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isFormValid: Bool = false
    
    private var generatedCode: String?
    private var codeExpirationDate: Date?
    private var foundUser: (id: String, email: String, username: String)?
    
    // MARK: - Init
    init(userManager: UserManagerProtocol) {
        self.userManager = userManager
    }
    private func updateFormValidity() {
        if isLoginMode {
            // Режим Логин: проверяем логин и пароль
            isFormValid = !username.isEmpty && !password.isEmpty
        } else {
            // Режим Email: проверяем email
            isFormValid = !email.isEmpty && isEmailValid(email)
        }
        
        print("📝 isFormValid: \(isFormValid), isLoginMode: \(isLoginMode), username: \(username), password: \(password.isEmpty), email: \(email)")
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

    // MARK: - 1. Логин + Пароль
    func loginWithPassword() {
        isLoading = true
        errorMessage = nil
        
        let loginName = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !loginName.isEmpty else {
            isLoading = false
            errorMessage = "Введите логин"
            return
        }
        
        print("🔍 Ищем пользователя с логином: \(loginName)")
        
        db.collection(FirestoreCollections.users).whereField("username", isEqualTo: loginName).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка: \(error)")
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("❌ Пользователь не найден")
                    self?.isLoading = false
                    self?.errorMessage = "userNotFound".localized
                    return
                }
                
                let data = document.data()
                let storedPassword = data["password"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let userId = document.documentID
                
                guard self?.password == storedPassword else {
                    print("❌ Неверный пароль")
                    self?.isLoading = false
                    self?.errorMessage = "Неверный пароль"
                    return
                }
                
                print("✅ Пароль верный, вход выполнен")
                
                let user = User(id: userId, email: email, username: loginName)
                self?.userManager.saveUser(user)
                self?.loginSuccess = true
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - 2. Email + Код (отправка)
    func sendCodeToEmail() {
        isLoading = true
        errorMessage = nil
        
        let emailAddress = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !emailAddress.isEmpty else {
            isLoading = false
            errorMessage = "enterEmail".localized 
            return
        }
        
        print("🔍 Ищем пользователя с email: \(emailAddress)")
        
        db.collection(FirestoreCollections.users).whereField("email", isEqualTo: emailAddress).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка: \(error)")
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("❌ Пользователь с email \(emailAddress) не найден")
                    self?.isLoading = false
                    self?.errorMessage = "userNotFound".localized
                    return
                }
                
                let data = document.data()
                self?.foundUser = (
                    id: document.documentID,
                    email: data["email"] as? String ?? "",
                    username: data["username"] as? String ?? ""
                )
                
                print("✅ Пользователь найден: \(self?.foundUser?.username ?? "")")
                self?.sendCode()
            }
        }
    }
    
    private func sendCode() {
        let code = String(format: "%06d", Int.random(in: 0...999999))
        generatedCode = code
        codeExpirationDate = Date().addingTimeInterval(15 * 60)
        
        print("📧 Код для входа: \(code) на \(email)")
        
        EmailService.shared.sendVerificationCode(to: email, code: code) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.emailSent = true
                    self?.codeSent = true
                    print("✅ Код отправлен")
                case .failure(let error):
                    self?.errorMessage = "\("error".localized): \(error.localizedDescription)"
                    print("❌ Ошибка отправки: \(error)")
                }
            }
        }
    }
    
    // MARK: - 3. Проверка кода и вход (без пароля)
    func verifyCodeAndLogin(_ enteredCode: String) {
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
        
        guard let user = foundUser else {
            isLoading = false
            errorMessage = "emailNotExists".localized
            return
        }
        
        print("✅ Код верный, вход выполнен для \(user.username)")
        
        let appUser = User(id: user.id, email: user.email, username: user.username)
        userManager.saveUser(appUser)
        
        isLoading = false
        loginSuccess = true
    }
    
    // MARK: - Helpers
    func updateAuthMode(isLoginMode: Bool) {
        self.isLoginMode = isLoginMode
        updateFormValidity()
        //clearFields()
    }
    
    func clearFields() {
        username = ""
        email = ""
        password = ""
        errorMessage = nil
        codeSent = false
        emailSent = false
        generatedCode = nil
        codeExpirationDate = nil
        foundUser = nil
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
