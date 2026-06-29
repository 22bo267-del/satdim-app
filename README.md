# Satdim.az Android Tətbiqi

## Bu tətbiq nə edir?
- satdim.az saytını WebView içində açır
- Android FLAG_SECURE ilə **ekran görüntüsünü bloklayır**
- Sağ klik və mətn seçimini əngəlləyir

---

## APK build etmək üçün addımlar

### 1. Flutter yüklə
https://flutter.dev/docs/get-started/install adresinə get və Flutter SDK yüklə.

### 2. Android Studio yüklə
https://developer.android.com/studio — yükləyib quraşdır.

### 3. Bu qovluğu aç
Terminal və ya Command Prompt-da bu qovluğa gəl:
```
cd satdim_app
```

### 4. Asılılıqları yüklə
```
flutter pub get
```

### 5. APK build et
```
flutter build apk --release
```

### 6. APK-nı tap
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Qeyd
- FLAG_SECURE yalnız Android-də işləyir
- iOS üçün ayrıca AppStore prosesi lazımdır
- Minimum Android versiyası: 5.0 (API 21)
