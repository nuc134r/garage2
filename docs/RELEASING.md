# Releasing

Two GitHub Actions workflows publish the app:

| Workflow | Trigger | Output |
|---|---|---|
| `pages.yml` | every push to `main` | web app at https://nuc134r.github.io/garage2/ |
| `release.yml` | pushing a `v*` tag | signed APKs attached to a GitHub release |

## One-time setup

### 1. Enable GitHub Pages

Repo **Settings → Pages → Build and deployment → Source: GitHub Actions**.

### 2. Create an upload keystore

Android only installs an update if it is signed with the **same key** as the installed app, so
create one key and keep it forever. Back up the `.jks` file and its passwords somewhere safe
(password manager); if you lose them, users must uninstall to get new versions.

Run this on your machine **outside the repo** (keystores are git-ignored, but don't risk it):

```bash
keytool -genkeypair -v -keystore C:\Users\chelm\keys\garage-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias garage
```

`keytool` comes with any JDK, e.g. `C:\Program Files\Java\jdk-17.0.2\bin\keytool.exe`.
It asks for a keystore password, your name (anything is fine) and a key password
(press Enter to reuse the keystore password).

### 3. Add repository secrets

Repo **Settings → Secrets and variables → Actions → New repository secret**:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | the `.jks` file, base64-encoded (see below) |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | `garage` (the `-alias` above) |
| `ANDROID_KEY_PASSWORD` | key password (same as keystore password if you pressed Enter) |

Base64-encode the keystore and copy it to the clipboard (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Users\chelm\keys\garage-upload.jks")) | Set-Clipboard
```

Or with the GitHub CLI (`gh auth login` first):

```bash
gh secret set ANDROID_KEYSTORE_BASE64 --body "$(base64 -w0 ~/keys/garage-upload.jks)"
gh secret set ANDROID_KEYSTORE_PASSWORD
gh secret set ANDROID_KEY_ALIAS --body garage
gh secret set ANDROID_KEY_PASSWORD
```

Without these secrets the workflow still runs, but signs with a throwaway debug key and prints
a warning — fine for testing, not for real releases.

## Making a release

1. Make sure `main` is green (Actions tab) and `CHANGELOG.md` has a `## <version>` section —
   it becomes the release notes (and the "What's new" text of the in-app update card).
   After editing old sections, run **Actions → Sync release notes** to update existing releases.
2. Tag and push:

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

   Or, without git: **Actions → Release APK → Run workflow** on `main` with *version* `1.0.0` — the
   workflow tags the commit it built and publishes the release the same way.

3. The **Release APK** workflow builds and publishes a release named *garage 1.0.0* with:
   - `garage-1.0.0.apk` — universal, works on any phone (largest)
   - `garage-1.0.0-arm64-v8a.apk` — most modern phones (smallest)
   - `garage-1.0.0-armeabi-v7a.apk`, `garage-1.0.0-x86_64.apk` — older phones / emulators

Versioning: the version name comes from the tag (`v1.2.3` → `1.2.3`); the version code is the
workflow run number, so it always increases. Tags with a suffix (`v1.1.0-beta.1`) are published
as pre-releases.

To build APKs **without** releasing, open **Actions → Release APK → Run workflow**; the APKs are
attached to the run as an artifact.

The workflow runs the tests and the APK build as parallel jobs and publishes only when both pass.
Gradle's downloads and build cache (`gradle/actions/setup-gradle`) and the Android NDK + CMake
(`actions/cache`, versions pinned in the workflow) are cached between runs; after a Flutter upgrade,
check the build log for a new NDK being installed and bump the cache paths.

## Signed release builds locally

Create `android/key.properties` (git-ignored):

```properties
storeFile=C:\\Users\\chelm\\keys\\garage-upload.jks
storePassword=...
keyAlias=garage
keyPassword=...
```

Then `fvm flutter build apk --release`. Without the file, local release builds use the debug key.

## Installing on the phone

Download the APK from the release page on the phone and open it; allow "Install unknown apps"
for the browser when asked. The app id is `io.nuc134r.garage2`, so it installs next to the old app.
