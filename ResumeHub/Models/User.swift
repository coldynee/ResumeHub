//
//  User.swift
//  ResumeHub
//
//  Created by Никита Морозов on 27.03.2026.
//

import Foundation

struct User: Codable {
    let id: String
    var email: String
    var username: String
    var firstName: String?
    var lastName: String?
    var isApplicant: Bool
    
    var fullName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else if let lastName = lastName {
            return lastName
        } else {
             return username
        }
    }
    
    init(id: String, email: String, username: String, firstName: String? = nil, lastName: String? = nil, isApplicant: Bool = true) {
        self.id = id
        self.email = email
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.isApplicant = isApplicant
        }
    
}
