# Mobile APK updates

Android updates cannot be silently installed by an ordinary Flutter app. Android requires an installation confirmation for APKs installed outside a managed app store.

Recommended rollout:
1. Build a signed release APK using the same Android signing key for every release.
2. Publish the APK and release notes to GitHub Releases or a trusted distribution channel.
3. Store the current version, minimum supported version, release URL, SHA-256 digest and release notes in a small Firestore `app_config/mobile_release` document.
4. The Flutter app checks this document at startup and periodically while active.
5. If an update is available, show version and release notes; download the APK over HTTPS; verify its SHA-256 digest; then launch Android's package installer so the user can approve installation.
6. Never download or install executable packages from an arbitrary URL. Restrict update metadata writes to trusted administrators.

Preferred production option: publish the app in Google Play and use Play's managed update flow. Play can automatically update eligible apps according to user/device Play settings. The app itself should still show an update-required message for a critical minimum version.

Signing:
- Keep the Android upload/signing key and passwords out of Git and out of the APK.
- Store signing material in protected CI secrets.
- Back up the signing key securely; losing it can prevent updates to the existing app identity.
- Keep the Android application ID stable between releases.

A normal Android APK update preserves app-private data when package ID and signing identity remain the same. Test upgrades from the currently installed version before wide release.
