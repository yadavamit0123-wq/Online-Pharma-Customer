# Online Pharma — Flutter Customer App (APK / AAB)

Native Flutter customer app for Online Pharma.

| Item | Value |
|------|-------|
| App name | Online Pharma |
| Package | `com.pt.onlinepharma` |
| API | `https://admin.onlinepharma.co.in/api/` |
| Deep link scheme | `onlinepharma://` |

---

## GitHub Secrets (Settings → Secrets → Actions)

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | JKS base64 (single line) |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `key0` |
| `ANDROID_KEY_PASSWORD` | Key password |

Encode keystore:

```bash
base64 -i "/path/to/your.jks" | tr -d '\n' | pbcopy
```

---

## GitHub build

1. Push to `main`
2. **Actions → Build Flutter Customer APK and AAB → Run workflow**
3. Download artifacts: APK + AAB

---

## Local build

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
flutter build appbundle --release
```

Copy `android/key.properties.example` → `android/key.properties` and set your keystore path.

---

## Config files

| File | Purpose |
|------|---------|
| `lib/config/constant.dart` | API URL, app name, map key |
| `lib/firebase_options.dart` | Firebase Android/iOS |
| `android/app/google-services.json` | Firebase Android |
| `assets/images/app_launcher_logo/` | Square app icon source |
| `assets/images/app_logos/` | Rectangle logos (login/splash) |

Regenerate logos:

```bash
python3 scripts/generate_logos.py
dart run flutter_launcher_icons
```
