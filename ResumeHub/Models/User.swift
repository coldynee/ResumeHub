//
//  User.swift
//  ResumeHub
//
//  Created by Никита Морозов on 27.03.2026.
//

import Foundation
import FirebaseAuth

struct User: Codable {
    let id: String
    var email: String
    var username: String
    
    init(id: String, email: String, username: String) {
        self.id = id
        self.email = email
        self.username = username
    }
    
}
