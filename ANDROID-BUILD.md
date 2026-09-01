# Online Pharma Customer — Android APK / AAB (GitHub Actions)

Customer app = **PWA website** wrapped as **TWA** (Trusted Web Activity) for Play Store.

| Item | Value |
|------|-------|
| App name | Online Pharma |
| Package | `com.pt.onlinepharma` |
| Website / TWA URL | `https://onlinepharma.co.in` |
| API | `https://admin.onlinepharma.co.in` |
| Deep link scheme | `onlinepharma://` |

---

## 1. GitHub Secrets (repo → Settings → Secrets → Actions)

Run on Mac **once** to get keystore base64 (single line, no line breaks):

```bash
base64 -i "/Users/amityadav/Downloads/prt (2).jks" | tr -d '\n' | pbcopy
```

> **Note:** Many `.jks` files from Android Studio are actually **PKCS12** format. GitHub Actions converts them to JKS automatically before build. If local `./gradlew assembleRelease` fails with `Tag number over 30 is not supported`, convert once:
>
> ```bash
> keytool -importkeystore -noprompt \
>   -srckeystore "/Users/amityadav/Downloads/prt (2).jks" -srcstoretype PKCS12 \
>   -destkeystore android/app/release.jks -deststoretype JKS \
>   -alias key0
> ```

Add these **4 secrets**:

| Secret name | Value |
|-------------|-------|
| `KEYSTORE_BASE64` | Paste base64 output (entire string) |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | `key0` |
| `KEY_PASSWORD` | Key password |

**Never commit `.jks` or passwords to git.**

---

## 2. Run GitHub build

1. Push `Online-Pharma-Customer` to GitHub
2. **Actions** → **Build Android APK and AAB** → **Run workflow**
3. Wait ~5–10 min
4. Download artifacts:
   - `online-pharma-customer-apk` → install/test
   - `online-pharma-customer-aab` → upload to Play Console

Build job summary shows **SHA1** and **SHA256** fingerprints.

---

## 3. assetlinks.json (required for TWA / Play Store)

After first build, copy **SHA256** from GitHub job summary.

Update `public/.well-known/assetlinks.json`:

```json
"sha256_cert_fingerprints": [
  "AA:BB:CC:..."
]
```

Remove colons OR keep colons — Google accepts `AA:BB:CC:...` format.

Then rebuild website and upload `out/` to server:

```bash
npm install
npm run build
node create-htaccess.js
# upload out/ to public_html
```

Verify: https://onlinepharma.co.in/.well-known/assetlinks.json

---

## 4. Firebase (already done)

- `android/app/google-services.json` — committed (package `com.pt.onlinepharma`)
- Add **SHA-1** and **SHA-256** from GitHub build to Firebase Console → Project settings → Android app

---

## 5. Admin panel settings

| Admin path | Set |
|------------|-----|
| Settings → App | Customer Play Store link (after publish), App Scheme: `onlinepharma` |
| Settings → Web | PWA name: Online Pharma, logos 144/192/512 |
| Settings → Authentication | Firebase web keys + Google Map key |
| Settings → Notification | VAPID key |

Map key provided separately for admin.

---

## 6. Play Store upload

1. Google Play Console → Create app **Online Pharma**
2. Upload **AAB** from GitHub artifact
3. Privacy policy: `https://onlinepharma.co.in/privacy-policy/`
4. Feature graphic 1024×500 + 2 screenshots

---

## 7. Local build (optional)

Requires Android Studio + JDK 17:

```bash
cd android
cp keystore.properties.example keystore.properties
# edit keystore.properties
cp "/path/to/prt (2).jks" app/release.keystore
./gradlew assembleRelease bundleRelease
```

Outputs:
- `app/build/outputs/apk/release/app-release.apk`
- `app/build/outputs/bundle/release/app-release.aab`

---

## Folder structure

```
Online-Pharma-Customer/
├── android/                 ← TWA project (APK/AAB)
├── .github/workflows/       ← GitHub CI
├── public/
│   ├── logo-144/192/512.png
│   ├── manifest.json
│   └── .well-known/assetlinks.json
└── .env                     ← domain URLs for PWA build
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| App opens browser not full screen | assetlinks.json missing/wrong SHA256 on live site |
| Build fails signing | Check GitHub secrets |
| Firebase push not working | Add SHA fingerprints in Firebase console |
| Website shows old logo | Rebuild PWA + re-upload `out/` |
