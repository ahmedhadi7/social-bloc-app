# 💬 Social Bloc | تطبيق التواصل الاجتماعي

A cross-platform social media app built with **Flutter**, **Bloc/Cubit** and **Firebase**, following Clean Architecture principles.
تطبيق تواصل اجتماعي يعمل على الموبايل والويب، مبني بـ Flutter وFirebase.

## ✨ Features | المميزات

- 🔐 Authentication (register / login / logout) with Firebase Auth
- 📝 Create posts with text and images (mobile and web upload)
- ❤️ Like / unlike posts with optimistic UI updates
- 💬 Add and delete comments
- 👤 User profiles: edit name, bio and profile picture
- ➕ Follow / unfollow users, followers and following lists
- 🔎 Search for users by name
- 🌗 Light and Dark mode
- 📱 Responsive layout (constrained width for web and desktop)
- 🇮🇶 Arabic welcome screen and UI

## 🛠️ Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | flutter_bloc (Cubit) |
| Backend | Firebase Auth, Cloud Firestore, Firebase Storage |
| Images | cached_network_image, file_picker |
| Architecture | Clean Architecture (domain / data / presentation) |

## 📂 Project Structure

```
lib/
├── config/            # Firebase options
├── features/
│   ├── auth/          # Login, register, auth cubit
│   ├── home/          # Home page, drawer, welcome page
│   ├── post/          # Posts, likes, comments
│   ├── profile/       # Profile, edit profile, follow
│   ├── search/        # User search
│   ├── settings/      # Dark mode toggle
│   └── storage/       # Firebase Storage repo
├── responsive/        # ConstrainedScaffold
├── themes/            # Light / dark themes + ThemeCubit
├── app.dart           # Root widget and BlocProviders
└── main.dart
```

Each feature is split into `domain` (entities, repo contracts), `data` (Firebase implementations) and `presentation` (cubits, pages, components).

## 🚀 Getting Started

1. Clone the repo
   ```bash
   git clone https://github.com/ahmedhadi7/social-bloc-app.git
   cd social-bloc-app
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Configure Firebase
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Make sure the generated file is at `lib/config/firebase_options.dart`.
4. In the Firebase Console enable:
   - **Authentication** → Email/Password
   - **Cloud Firestore**
   - **Storage**
5. Run
   ```bash
   flutter run
   ```

## 🔒 Example Firebase Rules

**Firestore**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
                    && request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null;
      allow delete: if request.auth != null
                    && resource.data.userId == request.auth.uid;
    }
  }
}
```

**Storage**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 🗺️ Roadmap

- [ ] Real-time updates with Firestore streams
- [ ] Pagination for the feed
- [ ] Notifications for likes, comments and follows
- [ ] Localization (Arabic / English switch)
- [ ] Unit and widget tests

## 👨‍💻 Author

**Ahmed Hadi** | [GitHub](https://github.com/ahmedhadi7)

## 📄 License

MIT
