# 🔐 Pazartesi Başlıyorum - Yedek Bilgileri

## ✅ Yedeklenen Kritik Dosyalar (13 Ekim 2025)

Bu commit'te artık tüm kritik dosyalar GitHub'a yedeklenmiştir.

### 🔥 Firebase Konfigürasyonu
- ✅ `android/app/google-services.json` - Firebase Android config
- ✅ `lib/firebase_options.dart` - Firebase Flutter options
- 📦 Package: `com.loncagames.pazartesibasliyorum`

### 🔐 Android Signing (İmzalama)
- ✅ `android/app/upload-keystore.jks` - Release imza anahtarı
- ✅ `android/key.properties` - İmza konfigürasyonu
  - Şifre: `542.Ezu.143.`
  - Alias: `upload`
  - Store dosyası: `upload-keystore.jks`

### 📱 Build Dosyaları
- ✅ `android/app/build.gradle` - Build configuration
  - Desugaring enabled (flutter_local_notifications için)
  - ProGuard enabled
  - Signing config
- ✅ `android/app/proguard-rules.pro` - ProGuard kuralları
- ✅ `android/app/src/main/AndroidManifest.xml` - Permissions & config
- ✅ `android/app/src/main/res/drawable/app_icon.xml` - Notification icon

### 📦 Uygulama Bilgileri
- **App Name:** Pazartesi Başlıyorum
- **Package:** com.loncagames.pazartesibasliyorum
- **Version:** 1.0.0+1
- **Min SDK:** 26 (Android 8.0)
- **Target SDK:** 36

## 🎯 Tamamlanan Özellikler

### ✅ Part 1: Temel Özellikler
- Firebase Authentication (Email, Google Sign-In)
- Habit CRUD operations
- User profile management
- Clean Architecture implementation

### ✅ Part 2: İleri Özellikler
- Check-in system (4 components)
- Statistics & Charts (7 widgets)
- Achievement system (10 badge types)
- Streak recovery
- Data export/import

### ✅ Part 3: Offline-First
- Hive local database
- Sync queue system
- Connectivity monitoring
- Auto-sync when online
- Initial sync on first login
- Offline-first repository pattern

### ✅ Part 4: Sosyal Özellikler
- Friend system (add, accept, reject, remove)
- User search by username
- Habit sharing with friends
- Real-time friend/shared habit streams
- Social screen with 3 tabs

## 🚀 Build Komutları

### Debug Build
```bash
flutter build apk --debug
```

### Release AAB (Google Play için)
```bash
flutter build appbundle --release
```
Çıktı: `build/app/outputs/bundle/release/app-release.aab`

### Release APK
```bash
flutter build apk --release
```
Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

## 📊 Proje İstatistikleri

- **Total Dart Files:** 200+
- **Features:** 7 (auth, habits, achievements, statistics, social, profile, goals)
- **Services:** 8 (sync, notification, push, connectivity, export, analytics)
- **Widgets:** 50+
- **Lines of Code:** ~20,000+

## ⚠️ Önemli Notlar

### 🔒 Güvenlik
- **keystore.jks** ve **key.properties** dosyaları GitHub'da!
- Prodüksiyon için bu dosyaları `.gitignore`'a ekleyin
- Sadece geliştirme/yedek amaçlı tutulmalı

### 🔥 Firebase
- **google-services.json** GitHub'da!
- API key'ler dosyada açıkça görünür
- Firebase Console'dan IP restrictions ekleyin

### 🔐 Şifreler
- Keystore şifresi: `542.Ezu.143.`
- Bu şifre commit mesajında ve bu dosyada var
- Prodüksiyon için değiştirin ve güvenli tutun

## 📝 .gitignore Durumu

`.gitignore` dosyası şu anda **kritik dosyaları yedeklemek için** düzenlenmiştir:

```gitignore
# Firebase - COMMENTED OUT FOR BACKUP
# **/google-services.json
# **/GoogleService-Info.plist
# firebase_options.dart

# Android Keys - COMMENTED OUT FOR BACKUP
# **/android/key.properties
# *.jks
```

### ⚙️ Prodüksiyon İçin
Prodüksiyona geçerken bu satırları aktif edin (# işaretini kaldırın):

```gitignore
# Firebase
**/google-services.json
**/GoogleService-Info.plist
firebase_options.dart

# Android Keys
**/android/key.properties
*.jks
```

## 🔄 Restore (Geri Yükleme) İşlemi

Eğer dosyalar kaybedilirse:

```bash
# 1. Projeyi klonla
git clone https://github.com/eyzaun/pazartesi-basliyorum.git

# 2. Dependencies'leri yükle
flutter pub get

# 3. Build runner çalıştır (Hive adapters için)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Build yap
flutter build appbundle --release
```

Tüm kritik dosyalar zaten repository'de olduğu için başka bir şey yapmanıza gerek yok!

## 📞 İletişim

**Developer:** Lonca Games  
**Repository:** https://github.com/eyzaun/pazartesi-basliyorum  
**Commit:** c92c654 (13 Ekim 2025)  

---

**⚠️ ÖNEMLİ:** Bu dosya kritik güvenlik bilgileri içerir. Prodüksiyona geçmeden önce:
1. Yeni bir keystore oluşturun
2. Firebase projesinde IP restrictions ekleyin
3. Tüm kritik dosyaları .gitignore'a ekleyin
4. Bu dosyayı silin veya düzenleyin
