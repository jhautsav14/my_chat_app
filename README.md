# 💬 Real-Time Team Chat Platform

A full-featured real-time team chat application built with **Flutter**, **GetX**, and **Firebase**. Supports private and group messaging, typing indicators, seen status, user search, and more!

---
## 🧪 Screenshots

| Login | Signup | Homepage |
|-------|--------|----------|
| ![Login](assets/ss/l1.png) | ![Signup](assets/ss/l2.png) | ![Homepage](assets/ss/l3.png) |

| Create Group | Private Chat | Group Chat |
|--------------|--------------|------------|
| ![Create Group](assets/ss/l4.png) | ![Private Chat](assets/ss/l5.png) | ![Group Chat](assets/ss/l6.png) |


## 🚀 Features

- 🔐 Firebase Authentication (Sign up, Login, Logout)
- 👤 Emoji-based user profiles
- 💬 One-on-One & Group Chats
- ⏱ Real-Time Messaging via Firebase Firestore
- 🕓 Message Seen/Sent Indicators
- ✍️ Typing Indicators (real-time updates)
- 🔎 Search users by email
- 📱 Responsive UI with GetX

---

## 📦 Tech Stack

- **Flutter** (3.x)
- **Dart**
- **Firebase Auth**
- **Cloud Firestore**
- **GetX** (state management and navigation)
- **emoji_picker_flutter**

---

## 🛠 Setup Instructions

### 1. Clone the Repo

```bash
git clone https://github.com/your-username/my_chat_app.git
cd my_chat_app
```


## 2. Install Dependencies
```bash
flutter pub get
```
## 3. Firebase Setup
-Create a Firebase project at console.firebase.google.com

-Enable Email/Password Authentication

-Set up Cloud Firestore

-Download google-services.json and place it in android/app/

## 4. Run the App
```bash
flutter run
📁 Project Structure
lib/
├── app/
│   ├── modules/
│   │   ├── auth/           # Authentication screens and logic
│   │   ├── chat/           # ChatPage and messaging
│   │   ├── home/           # Home screen and chat list
│   │   └── group_create/   # Group chat creation flow
│   ├── controllers/        # GetX Controllers
│   └── routes/             # Route configuration
🧪 Screenshots
Login	Chat Screen	Group Creation
```

## 📄 License
This project is licensed under the MIT License.

- 🌟 Future Enhancements
- 📎 File/Image Sharing
- 👨‍💼 Admin Controls
- 📊 Delivery Analytics

## 👨‍💻 Author
Utsav Kumar
[GitHub](https://github.com/jhautsav14)
