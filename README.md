# SentroG — Sentro Ginhawa development repository

This repository is being prepared for Raspberry Pi 5 deployment. The kiosk uses a Tkinter GUI and must run on Raspberry Pi OS/Linux; a Windows `.exe` is not compatible with Raspberry Pi OS. Build a native ARM executable on the Pi with PyInstaller.

## Planned deployment

- `kiosk/`: kiosk application source
- `mobile/`: Flutter resident application
- `scripts/`: installer, native executable build, and startup update workflow
- `.env.example`: variable names only; put real credentials on the device, never in Git

## Security

This repository is public. Do not commit actual passwords, email app passwords, Firebase private keys, resident databases, or any production credentials. Temporary development does not make public Git history safe for secrets. Use local configuration at `~/.config/sentrog/.env` and local data at `~/.local/share/sentrog/`. Rotate any credential previously included in a shared archive.

## Current status

Initial repository bootstrap. Source files and Raspberry Pi packaging are being staged; do not use this repository as a deployable build until the application source, Firebase configuration, and hardware dependencies have been validated on a Raspberry Pi 5.