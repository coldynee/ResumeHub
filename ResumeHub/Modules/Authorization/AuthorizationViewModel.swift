//
//  AuthorizationViewModel.swift
//  ResumeHub
//
//  Created by Никита Морозов on 27.03.2026.
//

import Foundation
import Combine

final class AuthorizationViewModel {
    
    //MARK: Dependecies
    private let authService: AuthServiceProtocol
    private let userManager: UserManagerProtocol
    
    //MARK: State
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLoginMode = true
    @Published var loginSuccess = false
    
    //MARK: Input values
    
    var username: String = ""
    var password = ""
    var mail = ""
    
    //MARK: Init
    
    init(authService: AuthServiceProtocol, userManager: UserManagerProtocol) {
        self.authService = authService
        self.userManager = userManager
    }
    
    //MARK: Public methods
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        authService.login(username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.userManager.saveUser(user)
                    self?.loginSuccess = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
            
        }
    }
    
    func sendCodeToMail() {
        isLoading = true
        errorMessage = nil
        
        authService.sendAuthCode(to: mail) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.loginSuccess = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    
                }
            }
        }
    }
    
    func updateAuthMode(isLoginMode: Bool) {
        self.isLoginMode = isLoginMode
        clearFields()
    }
    
    func clearFields() {
        username = ""
        mail = ""
        password = ""
        errorMessage = nil
    }
}
