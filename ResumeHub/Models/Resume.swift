//
//  Resume.swift
//  ResumeHub
//
//  Created by Никита Морозов on 16.07.2026.
//

import Foundation
import FirebaseFirestore

struct Resume: Codable, Identifiable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    let description: String
    let salary: Int?
    let experience: String
    let skills: [String]
    let createdAt: Timestamp
    let updatedAt: Timestamp
    
    init(
        id: String? = nil,
        userId: String,
        title: String,
        description: String,
        salary: Int? = nil,
        experience: String,
        skills: [String] = [],
        createdAt: Timestamp = Timestamp(),
        updatedAt: Timestamp = Timestamp()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.salary = salary
        self.experience = experience
        self.skills = skills
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
