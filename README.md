<div align="center">

# ResumeHub

<div align="center">
  <b>
    <a href="README.md">🇷🇺 Русский</a> | 
    <a href="README.en.md">🇬🇧 English</a>
  </b>
</div>

<br>

**Платформа для публикации резюме и поиска работы**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue)](https://apple.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/coldynee/ResumeHub)](https://github.com/coldynee/ResumeHub/commits/main)

</div>

---

## О проекте

**ResumeHub** — это iOS-приложение, которое я разрабатываю для демонстрации навыков, необходимых Junior iOS-разработчику. Проект включает полный цикл аутентификации, работу с облачной базой данных и отправку email-уведомлений.

### Ключевые возможности

- Регистрация и вход: поддержка двух методов — логин/пароль и вход по одноразовому коду на email
- Восстановление пароля: автоматическая генерация нового пароля и отправка через SMTP
- Хранение пользователей в **Firebase Firestore**
- Отправка email через собственный **SMTP-клиент** (без сторонних SDK)
- Анимированный экран загрузки (Launch Screen)
- Локализация (русский / английский)
- Поддержка светлой и темной тем

---

## Технологии

| Область | Технологии |
|---------|-------------|
| **Язык** | Swift 5 |
| **UI** | UIKit, SnapKit, Auto Layout |
| **Архитектура** | MVVM, Coordinator |
| **Реактивность** | Combine |
| **Бэкенд и БД** | Firebase Firestore |
| **Сеть и почта** | URLSession, SMTP (собственная реализация) |
| **Инструменты** | Git, SPM |

---

## Анимация Launch Screen
<table>
  <tr>
    <th align="center">Светлая тема</th>
    <th align="center">Тёмная тема</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/LaunchScreen.gif" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/LaunchScreen.gif" width="300"/></td>
  </tr>
</table>

<br/>

---

## Скриншоты

### Экран авторизации по логину

<table>
  <tr>
    <th align="center">Светлая тема</th>
    <th align="center">Тёмная тема</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/LoginAuth.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/LoginAuth.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Экран авторизации по почте

<table>
  <tr>
    <th align="center">Светлая тема</th>
    <th align="center">Тёмная тема</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/EmailAuth.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/EmailAuth.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Экран регистрации

<table>
  <tr>
    <th align="center">Светлая тема</th>
    <th align="center">Тёмная тема</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/Registration.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/Registration.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Форма ввода кода с почты

<table>
  <tr>
    <th align="center">Светлая тема</th>
    <th align="center">Тёмная тема</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/CodeForm.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/CodeForm.png" width="300"/></td>
  </tr>
  
</table>

<br/>

### Форма ввода почты для восстановления доступа

<table>
  <tr>
    <th align="center">Светлая тема</th>
    <th align="center">Тёмная тема</th>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/Light/ForgotPassword.png" width="300"/></td>
    <td align="center"><img src="Screenshots/Dark/ForgotPassword.png" width="300"/></td>
  </tr>
  
</table>

<br/>

---

## Архитектура проекта

Проект построен на **MVVM + Coordinator**:
- **View** — только отображение (вёрстка кодом через SnapKit)
- **ViewModel** — бизнес-логика, валидация, вызовы сервисов
- **Coordinator** — вся навигация
- **Combine** — связывание View и ViewModel

---

## Планы по развитию

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

## Как запустить

1. Клонировать репозиторий  
   `git clone https://github.com/coldynee/ResumeHub.git`
2. Открыть `ResumeHub.xcodeproj`
3. Собрать и запустить (Cmd + R)

---

## Контакты

- Telegram: [@coldynee](https://t.me/coldynee)
- Email: [coldynee@gmail.com](mailto:coldynee@gmail.com)
- GitHub: [coldynee](https://github.com/coldynee)

---

## 📄 Лицензия

Проект создан в учебных целях.
