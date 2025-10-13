# Firebase Security Rules - Pazartesi Başlıyorum

## 📋 Genel Bakış
Bu dosya, "Pazartesi Başlıyorum" uygulaması için güvenli Firebase Rules yapılandırmasını içerir.

## 🔐 Güvenlik Prensipleri
- ✅ Sadece authenticate edilmiş kullanıcılar erişebilir
- ✅ Her kullanıcı sadece kendi datasına erişebilir
- ✅ Dosya boyutu ve tip kontrolü yapılır
- ✅ Unauthorized access engellenir

---

## 1️⃣ Firestore Database Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }
    
    // Habits collection - users can only access their own habits
    match /habits/{habitId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Habit logs collection - users can only access their own logs
    match /habit_logs/{logId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isSignedIn() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Sync metadata - users can only access their own sync data
    match /sync_metadata/{docId} {
      allow read, write: if isSignedIn() && resource.data.userId == request.auth.uid;
    }
    
    // Block all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 2️⃣ Firebase Storage Rules

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    
    // User profile images - users can only upload their own profile images
    match /users/{userId}/profile/{imageId} {
      allow read: if true; // Profile images are public
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024 // Max 5MB
                   && request.resource.contentType.matches('image/.*'); // Only images
    }
    
    // Habit images - users can only upload images for their own habits
    match /habits/{userId}/{habitId}/{imageId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 10 * 1024 * 1024 // Max 10MB
                   && request.resource.contentType.matches('image/.*'); // Only images
    }
    
    // Block all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 3️⃣ Realtime Database Rules (Opsiyonel)

Eğer Realtime Database kullanıyorsanız:

```json
{
  "rules": {
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    },
    "habits": {
      "$habitId": {
        ".read": "data.child('userId').val() === auth.uid",
        ".write": "data.child('userId').val() === auth.uid || !data.exists()"
      }
    },
    "habit_logs": {
      "$logId": {
        ".read": "data.child('userId').val() === auth.uid",
        ".write": "data.child('userId').val() === auth.uid || !data.exists()"
      }
    }
  }
}
```

---

## 📝 Firebase Console'da Uygulama Adımları

### Firestore Rules
1. Firebase Console'a git: https://console.firebase.google.com
2. Projeyi seç: **pazartesi-basliyorum**
3. Sol menüden **Firestore Database** → **Rules** sekmesine tıkla
4. Yukarıdaki **Firestore Database Rules**'ı kopyala ve yapıştır
5. **Publish** butonuna tıkla

### Storage Rules
1. Firebase Console'da **Storage** bölümüne git
2. **Rules** sekmesine tıkla
3. Yukarıdaki **Firebase Storage Rules**'ı kopyala ve yapıştır
4. **Publish** butonuna tıkla

---

## ⚠️ ÖNEMLİ NOTLAR

### Test Mode (ŞU ANDA KULLANMA!)
```javascript
// TEHLİKELİ - Herkes her şeyi okuyabilir/yazabilir
allow read, write: if true;
```

### Production Mode (ŞİMDİ KULLAN!)
Yukarıdaki güvenli rules'ları kullan. Bunlar:
- ✅ Sadece authenticated kullanıcılar erişir
- ✅ Her kullanıcı sadece kendi datasına erişir
- ✅ Dosya boyutu kontrolü yapar (5MB profil, 10MB habit resimleri)
- ✅ Sadece image dosyalarına izin verir
- ✅ Unauthorized erişimleri engeller

---

## 🧪 Rules Test Etme

Firebase Console'da **Rules Playground** ile test edebilirsin:

```javascript
// Test 1: Kendi habitini okuma (BAŞARILI olmalı)
Location: /habits/habit123
Authenticated as: user123 
Operation: read
Data: { userId: "user123", name: "Spor" }
Result: ✅ ALLOW

// Test 2: Başkasının habitini okuma (REDDEDİLMELİ)
Location: /habits/habit456
Authenticated as: user123
Operation: read
Data: { userId: "user789", name: "Kitap" }
Result: ❌ DENY

// Test 3: Authentication olmadan okuma (REDDEDİLMELİ)
Location: /habits/habit123
Authenticated as: Not authenticated
Operation: read
Result: ❌ DENY
```

---

## 📱 Uygulama Data Yapısı

### Firestore Collections:

**users/{userId}**
```javascript
{
  id: "user123",
  email: "user@example.com",
  displayName: "Kullanıcı Adı",
  photoUrl: "https://...",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**habits/{habitId}**
```javascript
{
  id: "habit123",
  userId: "user123",  // Sahibi belirten alan (ZORUNLU)
  name: "Spor",
  icon: "🏃",
  color: "#FF5722",
  frequency: "daily",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

**habit_logs/{logId}**
```javascript
{
  id: "log123",
  habitId: "habit123",
  userId: "user123",  // Sahibi belirten alan (ZORUNLU)
  completedAt: timestamp,
  note: "Not",
  createdAt: timestamp
}
```

---

## 🔧 Troubleshooting

### Hata: "Missing or insufficient permissions"
**Çözüm**: Rules'ları kontrol et, `userId` alanının doğru set edildiğinden emin ol.

### Hata: "Storage object is too large"
**Çözüm**: Dosya boyutunu kontrol et (max 5MB profil, 10MB habit).

### Hata: "Caller does not have storage.objects.get permission"
**Çözüm**: Storage Rules'ı yukarıdaki şekilde güncelle.

---

## 📞 Destek

Sorun yaşarsan:
1. Firebase Console → Rules Playground'da test et
2. Browser Console'da hata mesajlarını kontrol et
3. Firebase error code'larını Google'da ara

---

**Son Güncelleme**: 13 Ekim 2025
**Proje**: Pazartesi Başlıyorum
**Firebase Project ID**: pazartesi-basliyorum
