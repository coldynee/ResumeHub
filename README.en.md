<div align="center">

# ResumeHub

<div align="center">
  <b>
    <a href="README.md">🇷🇺 Russian</a> | 
    <a href="README.en.md">🇬🇧 English</a>
  </b>
</div>

<br>

**Platform for publishing resumes and job search**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue)](https://apple.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/coldynee/ResumeHub)](https://github.com/coldynee/ResumeHub/commits/main)

</div>

---

## About the project

**ResumeHub** is an iOS application I'm developing to demonstrate the skills required for a Junior iOS Developer. The project includes a complete authentication cycle, cloud database integration, and email notifications.

### Key Features

- Registration and login: support for two methods — username/password and one-time code via email
- Password recovery: automatic generation of a new password and sending via SMTP
- User data storage in **Firebase Firestore**
- Email sending via custom **SMTP client** (no third-party SDKs)
- Animated Launch Screen
- Localization (Russian / English)
- Light and dark theme support

---

## Technologies

| Area | Technologies |
|------|--------------|
| **Language** | Swift 5 |
| **UI** | UIKit, SnapKit, Auto Layout |
| **Architecture** | MVVM, Coordinator |
| **Reactivity** | Combine |
| **Backend & DB** | Firebase Firestore |
| **Network & Email** | URLSession, SMTP (custom implementation) |
| **Tools** | Git, SPM |

---

## Launch Screen Animation

<table>
  <tr>
    <th align="center">Light Theme</th>
    <th align="center">Dark Theme</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/LaunchScreen.gif" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/LaunchScreen.gif" width="300"/></td>
  </tr>
</table>

<br/>

---

## Screenshots

### Login Authentication Screen

<table>
  <tr>
    <th align="center">Light Theme</th>
    <th align="center">Dark Theme</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/LoginAuth.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/LoginAuth.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Email Authentication Screen

<table>
  <tr>
    <th align="center">Light Theme</th>
    <th align="center">Dark Theme</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/EmailAuth.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/EmailAuth.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Registration Screen

<table>
  <tr>
    <th align="center">Light Theme</th>
    <th align="center">Dark Theme</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/Registration.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/Registration.png" width="300"/></td>
  </tr>
  
</tr>

<br/>

### Code Entry Form

<table>
  <tr>
    <th align="center">Light Theme</th>
    <th align="center">Dark Theme</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/CodeForm.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/CodeForm.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Forgot Password Form

<table>
  <tr>
    <th align="center">Light Theme</th>
    <th align="center">Dark Theme</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/ForgotPassword.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/ForgotPassword.png" width="300"/></td>
  </tr>
  
</table>

<br/>

---

## Project Architecture

The project is built on **MVVM + Coordinator**:
- **View** — display only (code-based layout using SnapKit)
- **ViewModel** — business logic, validation, service calls
- **Coordinator** — all navigation
- **Combine** — View and ViewModel binding

---

## Development Roadmap

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

## How to Run

1. Clone the repository  
   `git clone https://github.com/coldynee/ResumeHub.git`
2. Open `ResumeHub.xcodeproj`
3. Build and run (Cmd + R)

---

## Contacts

- Telegram: [@coldynee](https://t.me/coldynee)
- Email: [coldynee@gmail.com](mailto:coldynee@gmail.com)
- GitHub: [coldynee](https://github.com/coldynee)

---

## 📄 License

The project is created for educational purposes.
