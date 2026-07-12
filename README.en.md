<div align="center">

# 📱 ResumeHub

**Platform for publishing resumes and job search**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS-15.0+-blue?style=for-the-badge&logo=ios&logoColor=white)](https://apple.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/coldynee/ResumeHub?style=for-the-badge)](https://github.com/coldynee/ResumeHub/commits/main)

<div align="center">
  <b>
    <a href="README.md">🇷🇺 Russian</a> | 
    <a href="README.en.md">🇬🇧 English</a>
  </b>
</div>

</div>

---

## ✨ About the project

**ResumeHub** is an iOS application that I am developing to demonstrate the skills required for a Junior iOS Developer. The project includes a complete authentication cycle, cloud database integration, and email notifications.

### Key Features

<div align="center">

| | |
|---|---|
| 🔐 **Registration & Login** | Two methods: username/password + one‑time code via email |
| 🔄 **Password Recovery** | Automatic generation of a new password and sending via SMTP |
| ☁️ **Data Storage** | Users and resumes in **Firebase Firestore** |
| ✉️ **Email Notifications** | Custom **SMTP client** (no third‑party SDKs) |
| 🎬 **Animation** | Custom animated Launch Screen |
| 🌍 **Localization** | Russian and English interface |
| 🌓 **Themes** | Full support for light and dark themes |

</div>

---

## 🛠 Technologies

<p align="center">
  <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white" />
  <img src="https://img.shields.io/badge/SnapKit-FF9E0F?style=for-the-badge&logo=snapkit&logoColor=white" />
  <img src="https://img.shields.io/badge/Combine-FF4785?style=for-the-badge&logo=combine&logoColor=white" />
  <img src="https://img.shields.io/badge/MVVM-007AFF?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/Coordinator-4B0082?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" />
</p>

---

## 🎬 Launch Screen Animation

<div align="center">

| Light Theme | Dark Theme |
|:------------:|:-----------:|
| <img src="Screenshots/Light/LaunchScreen.gif" width="300"/> | <img src="Screenshots/Dark/LaunchScreen.gif" width="300"/> |

</div>

---

## 📱 Screenshots

<div align="center">

### 🔐 Login Authentication Screen

| Light Theme | Dark Theme |
|:------------:|:-----------:|
| <img src="Screenshots/Light/LoginAuth.png" width="300"/> | <img src="Screenshots/Dark/LoginAuth.png" width="300"/> |

### 📧 Email Authentication Screen

| Light Theme | Dark Theme |
|:------------:|:-----------:|
| <img src="Screenshots/Light/EmailAuth.png" width="300"/> | <img src="Screenshots/Dark/EmailAuth.png" width="300"/> |

### 📝 Registration Screen

| Light Theme | Dark Theme |
|:------------:|:-----------:|
| <img src="Screenshots/Light/Registration.png" width="300"/> | <img src="Screenshots/Dark/Registration.png" width="300"/> |

### ✉️ Code Entry Form

| Light Theme | Dark Theme |
|:------------:|:-----------:|
| <img src="Screenshots/Light/CodeForm.png" width="300"/> | <img src="Screenshots/Dark/CodeForm.png" width="300"/> |

### 🔓 Forgot Password Form

| Light Theme | Dark Theme |
|:------------:|:-----------:|
| <img src="Screenshots/Light/ForgotPassword.png" width="300"/> | <img src="Screenshots/Dark/ForgotPassword.png" width="300"/> |

</div>

---

## 🧠 Architecture

The project is built on **MVVM + Coordinator**:

| Component | Role |
|-----------|------|
| **View** | Display only (code‑based layout using SnapKit) |
| **ViewModel** | Business logic, validation, service calls |
| **Coordinator** | All navigation |
| **Combine** | View – ViewModel binding |

---

## 🚀 Roadmap

The project is actively evolving. Planned for the near future:

### 🔹 Core Features
- [ ] **Resume Feed** — view and filter published resumes
- [ ] **Profile Editing** — add avatar, bio, contact information
- [ ] **Save Resumes to Favorites** for job seekers and employers

### 🔹 Technical Improvements
- [ ] **Unit Tests** — cover key modules (ViewModel, ValidationService)
- [ ] **Password Hashing** — use `CryptoKit` for secure storage
- [ ] **CI/CD** — configure automated builds and tests via GitHub Actions

### 🔹 Additional
- [ ] **Push Notifications** — integrate Firebase Cloud Messaging
- [ ] **Biometrics (FaceID/TouchID)** — quick app login
- [ ] **CocoaPods** — experiment with dependency management on a real project

---

## 🚀 How to Run

1. Clone the repository  
   `git clone https://github.com/coldynee/ResumeHub.git`
2. Open `ResumeHub.xcodeproj`
3. Build and run (Cmd + R)

---

## 📫 Contacts

<p align="center">
  <a href="https://t.me/coldynee">
    <img src="https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" />
  </a>
  <a href="mailto:coldynee@gmail.com">
    <img src="https://img.shields.io/badge/Email-EA4335?style=for-the-badge&logo=gmail&logoColor=white" />
  </a>
  <a href="https://github.com/coldynee">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
  </a>
</p>

---

## 📄 License

The project is created for educational purposes.
