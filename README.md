# Pazartesi Başlıyorum 📅

Alışkanlık takip uygulaması - Track your habits, reach your goals!

## ✨ Features

### Phase 1: MVP (Completed)
- ✅ **Authentication System**
  - Email/Password authentication
  - Google Sign-In
  - Guest mode
  - User profile management
- ✅ **Clean Architecture**
  - Domain layer (entities, repositories, use cases)
  - Data layer (models, data sources, repository implementations)
  - Presentation layer (providers, screens, widgets)
- ✅ **Offline-First Approach**
  - Local database with Drift/SQLite (ready to implement)
  - Automatic sync with Firebase
- ✅ **Localization**
  - Turkish (tr)
  - English (en)
- ✅ **Theme Support**
  - Light mode
  - Dark mode
  - System auto

### Phase 2: Coming Soon
- 🔄 Habits CRUD operations
- 🔄 Daily check-in system
- 🔄 Statistics and analytics
- 🔄 Social features (habit sharing)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.35.5 or higher
- Dart 3.9.2 or higher
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/pazartesi_basliyorum.git
cd pazartesi_basliyorum
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Add Firebase configuration files**

   **For Android:**
   - Place `google-services.json` in `android/app/` directory
   
   **For Web:**
   - Configuration is already in `lib/firebase_options.dart`

4. **Run code generation**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Generate localization files**
```bash
flutter gen-l10n
```

### Running the App

**For Android:**
```bash
flutter run
```

**For Web:**
```bash
flutter run -d chrome
```

**For Windows:**
```bash
flutter run -d windows
```

## 📁 Project Structure

```
lib/
├── core/                       # Core functionality
│   ├── constants/             # App constants
│   ├── theme/                 # Theme configuration
│   ├── routing/               # Navigation/routing
│   └── utils/                 # Utility functions
├── features/                  # Feature modules
│   └── auth/                  # Authentication feature
│       ├── data/              # Data layer
│       ├── domain/            # Domain layer
│       └── presentation/      # Presentation layer
├── shared/                    # Shared resources
│   ├── models/                # Shared models
│   └── widgets/               # Shared widgets
├── l10n/                      # Localization files
├── firebase_options.dart      # Firebase configuration
└── main.dart                  # App entry point
```

## 🏗️ Architecture

This project follows **Clean Architecture** principles:

- **Domain Layer**: Business logic, entities, repository interfaces
- **Data Layer**: Data sources, models, repository implementations
- **Presentation Layer**: UI, state management with Riverpod

### Design Principles
- ✅ SOLID principles
- ✅ DRY (Don't Repeat Yourself)
- ✅ KISS (Keep It Simple, Stupid)
- ✅ Separation of Concerns
- ✅ Dependency Injection

## 🔥 Firebase Setup

### Collections Structure

**users**
```typescript
{
  userId: string,
  email: string,
  username: string,
  displayName: string,
  photoURL: string | null,
  createdAt: Timestamp,
  stats: {
    totalCompletions: number,
    currentStreak: number,
    longestStreak: number
  }
}
```

**habits** (Coming in Phase 2)
```typescript
{
  habitId: string,
  ownerId: string,
  name: string,
  description: string,
  category: string,
  frequency: object,
  // ... more fields
}
```

## 📱 Screens

### Authentication Flow
1. **Splash Screen** - App initialization
2. **Welcome Screen** - Sign in/Sign up options
3. **Sign In Screen** - Email or Google sign in
4. **Sign Up Screen** - Create new account
5. **Home Screen** - Main app interface (placeholder)

## 🛠️ Technologies

- **Framework**: Flutter 3.35.5
- **Language**: Dart 3.9.2
- **State Management**: Riverpod 2.6.1
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local Database**: Drift (SQLite)
- **UI Components**: Material 3
- **Authentication**: Firebase Auth + Google Sign-In

## 📦 Key Dependencies

```yaml
firebase_core: ^3.11.2
firebase_auth: ^5.4.0
cloud_firestore: ^5.6.0
google_sign_in: ^6.2.3
flutter_riverpod: ^2.6.1
drift: ^2.23.1
intl: ^0.20.1
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 🚧 Development Roadmap

### Phase 1: MVP ✅ (COMPLETED)
- [x] Authentication system
- [x] Clean architecture setup
- [x] Firebase integration
- [x] Localization
- [x] Theme support

### Phase 2: Core Features (In Progress)
- [ ] Habits CRUD
- [ ] Local database implementation
- [ ] Daily check-in system
- [ ] Basic statistics

### Phase 3: Advanced Features
- [ ] Social features
- [ ] Achievements
- [ ] Photo uploads
- [ ] Export/import data

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Developer

Built with ❤️ by Lonca Games

## 🎯 Next Steps

1. ✅ Complete Authentication (DONE)
2. 🔄 Implement Habits CRUD operations
3. 🔄 Set up local database with Drift
4. 🔄 Create Today screen with habit list
5. 🔄 Implement check-in system
6. 🔄 Add statistics and analytics

---

**Current Status**: Phase 2 (Habits CRUD) - ✅ COMPLETED

**Ready to build**: Yes! Run `flutter pub get` and `flutter run` to start the app.