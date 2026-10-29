# SentroG — Sentro Ginhawa

Repository for preparing the Sentro Ginhawa kiosk for Raspberry Pi 5 and the resident Flutter app.

## Build the Raspberry Pi 5 kiosk

1. Open the **Actions** tab.
2. Select **Build SentroG**.
3. Choose **Run workflow** and run it on `main`.
4. Open the completed run and download the `SentroGinhawa-RaspberryPi5-ARM64` artifact.

The workflow extracts the uploaded app archive, packages the refined Python kiosk for Linux ARM64, and intentionally excludes the uploaded `.env` and database files. The artifact is a CI build and still needs hardware testing on a Raspberry Pi 5 before production use.

A Windows `.exe` is not compatible with Raspberry Pi OS. Use the ARM64 build for a 64-bit Raspberry Pi OS installation.

## Flutter resident app status

The archive includes Flutter/Dart source files, but does not include the original Flutter project's `pubspec.yaml` or generated `firebase_options.dart`. The workflow reports this as a build blocker; it cannot produce a valid APK until those files are supplied. Do not invent Firebase configuration or commit private service-account keys.

## Security — public repository

Do not commit passwords, email app passwords, Firebase private keys, resident databases, or production credentials. The uploaded archive contains an `.env` with an email app password. **Revoke that password and generate a new one now.** Removing a secret from a future commit does not remove it from the already-published archive or Git history. Keep live configuration on the device, outside Git, for example at `~/.config/sentrog/.env`, and keep local data under `~/.local/share/sentrog/`.

## Current limitations

- The kiosk workflow builds a native ARM64 package but does not prove hardware behavior; test camera, serial sensor, printer, touchscreen, and email functions on the actual Pi.
- The Flutter app needs its complete project metadata and Firebase configuration before it can be built and tested.
- Do not use the build as a production deployment until these checks are complete.
