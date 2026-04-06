    //
    //  Constants.swift
    //  ResumeHub
    //
    //  Created by Никита Морозов on 05.04.2026.
    //

    import Foundation

    enum FirestoreCollections {
        static let users = "users"
        static let resumes = "resumes"
    }

    enum EmailConfig {
        static let fromEmail = "areuknow_mary@mail.ru"
        static let fromPassword = "1n46Ffx8N1eGJWEsENBP"
        static let smtpHost = "smtp.mail.ru"
        static let smtpPort: UInt16 = 465
    }

    enum UserDefaultsKeys {
        static let currentUser = "currentUser"
        static let emailForSignIn = "EmailForSignIn"
    }

    enum NotificationNames {
        static let signInLinkReceived = Notification.Name("SignInLinkReceived")
    }
