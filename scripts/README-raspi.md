# Raspberry Pi 5 installation

## Requirements
- Raspberry Pi 5 with Raspberry Pi OS 64-bit (Bookworm or newer)
- Internet for first install and updates
- A published GitHub Release containing `SentroGinhawa-RaspberryPi5-ARM64.zip`

## Install
1. Open Terminal on the Pi.
2. Run:
   ```bash
   sudo apt update
   sudo apt install -y git
   git clone https://github.com/karlnsp18-byte/SentroG.git
   cd SentroG
   chmod +x scripts/install_pi.sh
   ./scripts/install_pi.sh
   ```
3. Put kiosk-only settings in `/etc/sentrog/kiosk.env`. Never copy credentials into Git. Keep the Firebase service-account key outside the repository and restrict permissions:
   ```bash
   sudo install -d -m 700 /etc/sentrog/keys
   sudo install -m 600 /path/to/serviceAccount.json /etc/sentrog/keys/firebase.json
   sudo nano /etc/sentrog/kiosk.env
   ```
   Example:
   ```ini
   SENTRO_FIREBASE_KEY=/etc/sentrog/keys/firebase.json
   SENTRO_TZ_OFFSET=8
   IDLE_LOGOUT_SECONDS=90
   ```
4. Start a first manual test from the desktop terminal:
   ```bash
   sentrog-kiosk
   ```
5. Check the app, sensors, printer, camera/QR reader and a test record. Verify the record reaches the intended Firebase account. Do not use real patient data until security and consent checks are complete.

## Startup update behavior
The service runs a best-effort update check before launch. It downloads the latest public GitHub Release asset, compares the executable hash and replaces the installed bundle if it changed. The old bundle is retained in `/opt/sentrog/previous` for manual rollback. Updates do not alter `/var/lib/sentrog` or `/etc/sentrog`.

The installer creates a systemd unit template, but kiosk GUI startup should be enabled only after confirming the Pi's desktop session and display environment. For a normal Raspberry Pi desktop session, add an autostart desktop entry that runs `/usr/local/bin/sentrog-kiosk`. A graphical Tkinter app should not be launched as a headless system service without configuring the display session.

## Important limitations
- GitHub Actions build artifacts expire; the updater uses **GitHub Releases**, not temporary Actions artifacts.
- The updater currently uses public latest-release metadata and executable hashing; production deployment should add signed release checksums/signatures and staged rollout.
- This is a development installer, not yet a validated medical-device deployment. Test on the target Pi and connected peripherals.
- Firebase Admin SDK service-account credentials bypass Firestore Security Rules. A kiosk key is highly privileged: use a dedicated Firebase project, tightly restrict the key on the device, rotate it if exposed, and plan to move device writes behind a narrowly scoped authenticated backend endpoint.
