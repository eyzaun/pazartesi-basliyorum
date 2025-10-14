# Pazartesi Başlıyorum 📅# Pazartesi Başlıyorum 📅



**Alışkanlık takip uygulaması** - Hedeflerinizi ertelemeden gerçekleştirin!Alışkanlık takip uygulaması - Track your habits, reach your goals!



## 🚀 Hızlı Başlangıç## ✨ Features



```bash### Phase 1: MVP (Completed)

# Bağımlılıkları yükle- ✅ **Authentication System**

flutter pub get  - Email/Password authentication

  - Google Sign-In

# Çalıştır  - Guest mode

flutter run                    # Android/iOS  - User profile management

flutter run -d chrome          # Web- ✅ **Clean Architecture**

.\run.ps1                      # PowerShell script ile  - Domain layer (entities, repositories, use cases)

  - Data layer (models, data sources, repository implementations)

# Build  - Presentation layer (providers, screens, widgets)

flutter build apk --release    # Android APK- ✅ **Offline-First Approach**

flutter build appbundle        # Google Play AAB  - Local database with Drift/SQLite (ready to implement)

flutter build web --release    # Web  - Automatic sync with Firebase

```- ✅ **Localization**

  - Turkish (tr)

## ✨ Özellikler  - English (en)

- ✅ **Theme Support**

### ✅ Tamamlanan  - Light mode

- **Authentication**: Email/Password, Google Sign-In, Guest mode  - Dark mode

- **Habits**: CRUD, Categories, Frequency, Goals  - System auto

- **Check-in**: Daily tracking, Streak recovery, Completion stats

- **Statistics**: Charts, Analytics, Achievement badges### Phase 2: Coming Soon

- **Offline-First**: Hive local DB, Auto-sync, Conflict resolution- 🔄 Habits CRUD operations

- **Social**: Friends, Habit sharing, User search- 🔄 Daily check-in system

- **Localization**: Turkish/English- 🔄 Statistics and analytics

- **Theme**: Light/Dark mode- 🔄 Social features (habit sharing)



### 🌐 Deployment## 🚀 Getting Started

- **Web**: https://pazartesi-basliyorum.web.app

- **Android**: Ready for Google Play Store### Prerequisites

- **Package**: com.loncagames.pazartesibasliyorum

- Flutter SDK 3.35.5 or higher

## 📱 Teknolojiler- Dart 3.9.2 or higher

- Android Studio / VS Code

- **Flutter** 3.35.5 | **Dart** 3.9.2- Firebase account

- **State Management**: Riverpod 2.6.1

- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)### Installation

- **Local DB**: Hive 2.2.3

- **Charts**: fl_chart 0.68.01. **Clone the repository**

- **Architecture**: Clean Architecture (Domain/Data/Presentation)```bash

git clone https://github.com/yourusername/pazartesi_basliyorum.git

## 🛠️ Geliştirme Araçlarıcd pazartesi_basliyorum

```

### Wi-Fi Bağlantı (Telefon)

```bash2. **Install dependencies**

.\wifi-connect.ps1```bash

```flutter pub get

```

### Hızlı Çalıştırma

```bash3. **Add Firebase configuration files**

.\run.ps1              # Debug mode

.\run.ps1 -release     # Release mode   **For Android:**

```   - Place `google-services.json` in `android/app/` directory

   

### APK Kurulum   **For Web:**

```bash   - Configuration is already in `lib/firebase_options.dart`

.\install.ps1          # Release/Debug APK seçimi

```4. **Run code generation**

```bash

## 📦 Firebase Konfigürasyonuflutter pub run build_runner build --delete-conflicting-outputs

```

**Android**: `android/app/google-services.json`  

**Web**: `lib/firebase_options.dart`  5. **Generate localization files**

**Credentials**: `android/key.properties` (Şifre: 542.Ezu.143.)```bash

flutter gen-l10n

## 🏗️ Proje Yapısı```



```### Running the App

lib/

├── features/          # Auth, Habits, Statistics, Social, Achievements, Profile**For Android:**

├── core/             # Constants, Theme, Routing, Utils```bash

├── shared/           # Models, Widgets, Servicesflutter run

└── l10n/             # Turkish/English localization```

```

**For Web:**

## 👨‍💻 Developer```bash

flutter run -d chrome

**Lonca Games** | [GitHub](https://github.com/eyzaun/pazartesi-basliyorum)```



---**For Windows:**

```bash

**Version**: 1.0.2+3 | **Status**: Production Ready ✅flutter run -d windows

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