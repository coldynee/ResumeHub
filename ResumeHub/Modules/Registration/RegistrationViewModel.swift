//
//  RegistrationViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation
import Combine
import FirebaseAuth

final class RegistrationViewModel {
    
    //MARK: Dependecies
    private let authService: AuthServiceProtocol
    private let userManager: UserManagerProtocol
    
    //MARK: State
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var registerSuccess = false
    @Published var emailSent = false
    
    //MARK: Input values
    
    var username = ""
    var email = ""
    var password = ""
    
    //MARK: Init
    
    init(authService: AuthServiceProtocol, userManager: UserManagerProtocol) {
        self.authService = authService
        self.userManager = userManager
    }
    
    //MARK: Public methods
    
    func register() {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                print(self?.email ?? "", "registered")
                self?.registerSuccess = true
                self?.sendCodeToEmail()
            }
            
        }
        
        
//        authService.register(username: username, email: email, password: password) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                
//                switch result {
//                case .success(let user):
//                    self?.userManager.saveUser(user)
//                    self?.registerSuccess = true
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
    }
    
    func sendCodeToEmail() {
//        isLoading = true
//        errorMessage = nil
//        print("registered")
//        authService.sendAuthCode(to: email) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//
//                switch result {
//                case .success:
//                    self?.registerSuccess = true
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
        guard let user = Auth.auth().currentUser else { return }
        
        user.sendEmailVerification { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("error ", error.localizedDescription)
                } else {
                    print("letter send to ", self?.email ?? "")
                    self?.emailSent = true
                }
            }
            
        }
    }
    func checkEmailVerification() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        user.reload { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                if user.isEmailVerified {
                    print("email success")
                    
                }
            }
        }
    }
}
