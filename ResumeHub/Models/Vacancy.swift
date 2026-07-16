//
//  Vacancy.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import FirebaseFirestore

struct Vacancy: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let companyName: String
    let title: String
    let description: String
    let salary: Int?
    let requirements: [String]
    let location: String
    let createdAt: Timestamp 
    let updatedAt: Timestamp
    
    init(
        id: String? = nil,
        userId: String,
        companyName: String,
        title: String,
        description: String,
        salary: Int? = nil,
        requirements: [String] = [],
        location: String,
        createdAt: Timestamp = Timestamp(),
        updatedAt: Timestamp = Timestamp()
    ) {
        self.id = id
        self.userId = userId
        self.companyName = companyName
        self.title = title
        self.description = description
        self.salary = salary
        self.requirements = requirements
        self.location = location
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
