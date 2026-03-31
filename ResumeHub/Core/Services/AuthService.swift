//
//  AuthService.swift
//  ResumeHub
//
//  Created by Никита Морозов on 31.03.2026.
//

import Foundation

protocol AuthServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func sendAuthCode(to mail: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class AuthService: AuthServiceProtocol {
    func sendAuthCode(to mail: String, completion: @escaping (Result<Void, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if mail.contains("@") {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid email"])))
            }
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<User, any Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if username == "test" && password == "12345" {
                completion(.success(User(id: "1", username: username, email: "test@test.com")))
            } else {
                completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "invalidInputs".localized])))
            }
        }
    }
}
