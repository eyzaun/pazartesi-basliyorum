# Security & Secrets Guide

Bu dosya proje için acil güvenlik düzeltmeleri ve sürekli uygulama önerilerini içerir.

## Hızlı öncelikler (yapılacaklar)
1. `android/key.properties` içindeki parolaları derhal repo dışına çıkarın.
2. `android/app/upload-keystore.jks` gibi keystore dosyalarını repodan kaldırın ve güvenli bir depoda saklayın (ör. şirket secrets manager veya cloud KMS).
3. Git geçmişinde bulunan hassas dosyaları temizlemek için bir plan uygulayın (aşağıda komut örnekleri).
4. CI ortamında gerekli secret'ları (KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD, GOOGLE_SERVICES_JSON) ortam değişkenleri veya secret manager ile sağlayın.

## Yapılacak adımlar — kısa rehber
1) Geçici: local kopyayı tutun, ardından repodan dosyaları kaldırın:

```cmd
git rm --cached android/key.properties
git rm --cached android/app/upload-keystore.jks
git commit -m "chore: remove local keystore and key.properties from repo"
git push origin master
```

2) Geçmişten tamamen silme (tavsiye: `git filter-repo` veya BFG kullanın). BFG örneği:

```cmd
rem Windows için BFG kullanmadan önce Java kurulu olmalı
java -jar bfg.jar --delete-files upload-keystore.jks
java -jar bfg.jar --delete-files key.properties

rem ardından
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

Not: Bu adımlar remote branch'leri etkiler; team ile koordinasyon gerektirir (force push gerektirir).

3) `key.properties.template` oluşturun (repo içinde) ve gerçek parolaları CI secret olarak ayarlayın.

4) Firebase apiKey'leri genel olarak public kabul edilir, fakat üretim backend erişimleri için güvenli backend proxy ve kısıtlı OAuth client/sha certificate kullanın. Web API key'lerini console'da domain kısıtlamaları ile sınırlayın.

## Önerilen dosyalar (zaten oluşturuldu)
- `key.properties.template` — doldurulup CI veya geliştirici localinde `key.properties` olarak kullanılacak.
- `.gitignore` — `android/key.properties` ve `*.jks` için girişler eklendi.

## Süreç sonrası kontrol
- Secrets temizlendikten sonra CI pipeline'ı çalıştırın: `flutter analyze` ve `flutter test` başarılı olmalı.
- Yeni keystore/credential'ları güvenli ortamda saklayın (GCP Secret Manager, AWS Secrets Manager, GitHub Actions Secrets vb.).

If you want, I can generate a GitHub Actions workflow template that runs `flutter analyze` and `flutter test`, and shows how to inject the keystore from secrets for Android signing.
