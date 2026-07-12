<div align="center">

# 📱 ResumeHub

**Платформа для публикации резюме и поиска работы**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS-15.0+-blue?style=for-the-badge&logo=ios&logoColor=white)](https://apple.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/coldynee/ResumeHub?style=for-the-badge)](https://github.com/coldynee/ResumeHub/commits/main)

<div align="center">
  <b>
    <a href="README.md">🇷🇺 Русский</a> | 
    <a href="README.en.md">🇬🇧 English</a>
  </b>
</div>

</div>

---

## ✨ О проекте

**ResumeHub** — это iOS-приложение, которое я разрабатываю для демонстрации навыков, необходимых Junior iOS-разработчику. Проект включает полный цикл аутентификации, работу с облачной базой данных и отправку email-уведомлений.

### Ключевые возможности

<div align="center">

| | |
|---|---|
| 🔐 **Регистрация и вход** | Два метода: логин/пароль + одноразовый код на email |
| 🔄 **Восстановление пароля** | Автоматическая генерация нового пароля и отправка через SMTP |
| ☁️ **Хранение данных** | Пользователи и резюме в **Firebase Firestore** |
| ✉️ **Email-уведомления** | Собственный **SMTP-клиент** (без сторонних SDK) |
| 🎬 **Анимация** | Кастомный анимированный Launch Screen |
| 🌍 **Локализация** | Русский и английский интерфейс |
| 🌓 **Темы** | Полная поддержка светлой и тёмной темы |

</div>

---

## 🛠 Технологии

<p align="center">
  <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white" />
  <img src="https://img.shields.io/badge/SnapKit-FF9E0F?style=for-the-badge&logo=snapkit&logoColor=white" />
  <img src="https://img.shields.io/badge/Combine-FF4785?style=for-the-badge&logo=combine&logoColor=white" />
  <img src="https://img.shields.io/badge/MVVM-007AFF?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/Coordinator-4B0082?style=for-the-badge&logo=databricks&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style-for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" />
</p>

---

## 🎬 Анимация Launch Screen

<div align="center">

| Светлая тема | Тёмная тема |
|:------------:|:-----------:|
| <img src="Screenshots/Light/LaunchScreen.gif" width="300"/> | <img src="Screenshots/Dark/LaunchScreen.gif" width="300"/> |

</div>

---

## 📱 Скриншоты

<div align="center">

### 🔐 Экран авторизации по логину

| Светлая тема | Тёмная тема |
|:------------:|:-----------:|
| <img src="Screenshots/Light/LoginAuth.png" width="300"/> | <img src="Screenshots/Dark/LoginAuth.png" width="300"/> |

### 📧 Экран авторизации по почте

| Светлая тема | Тёмная тема |
|:------------:|:-----------:|
| <img src="Screenshots/Light/EmailAuth.png" width="300"/> | <img src="Screenshots/Dark/EmailAuth.png" width="300"/> |

### 📝 Экран регистрации

| Светлая тема | Тёмная тема |
|:------------:|:-----------:|
| <img src="Screenshots/Light/Registration.png" width="300"/> | <img src="Screenshots/Dark/Registration.png" width="300"/> |

### ✉️ Форма ввода кода

| Светлая тема | Тёмная тема |
|:------------:|:-----------:|
| <img src="Screenshots/Light/CodeForm.png" width="300"/> | <img src="Screenshots/Dark/CodeForm.png" width="300"/> |

### 🔓 Форма восстановления пароля

| Светлая тема | Тёмная тема |
|:------------:|:-----------:|
| <img src="Screenshots/Light/ForgotPassword.png" width="300"/> | <img src="Screenshots/Dark/ForgotPassword.png" width="300"/> |

</div>

---

## 🧠 Архитектура

Проект построен на **MVVM + Coordinator**:

| Компонент | Роль |
|-----------|------|
| **View** | Только отображение (вёрстка кодом через SnapKit) |
| **ViewModel** | Бизнес-логика, валидация, вызовы сервисов |
| **Coordinator** | Вся навигация |
| **Combine** | Связывание View и ViewModel |

---

## 🚀 Планы по развитию

Проект активно развивается. В ближайшее время планирую:

### 🔹 Основные функции
- [ ] **Лента резюме** — просмотр и фильтрация опубликованных резюме
- [ ] **Редактирование профиля** — добавление аватара, информации о себе, контактов
- [ ] **Сохранение резюме в избранное** у соискателей и работодателей

### 🔹 Технические улучшения
- [ ] **Unit-тесты** — покрытие ключевых модулей (ViewModel, ValidationService)
- [ ] **Хеширование паролей** — использование `CryptoKit` для безопасного хранения
- [ ] **CI/CD** — настройка автоматической сборки и тестов через GitHub Actions

### 🔹 Дополнительно
- [ ] **Push-уведомления** — интеграция Firebase Cloud Messaging
- [ ] **Биометрия (FaceID/TouchID)** — быстрый вход в приложение
- [ ] **CocoaPods** — опробовать управление зависимостями на реальном проекте

---

## 🚀 Как запустить

1. Клонировать репозиторий  
   `git clone https://github.com/coldynee/ResumeHub.git`
2. Открыть `ResumeHub.xcodeproj`
3. Собрать и запустить (Cmd + R)

---

## 📫 Контакты

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

## 📄 Лицензия

Проект создан в учебных целях.
