#!/usr/bin/env bash
set -euo pipefail
REPO="karlnsp18-byte/SentroG"
APP_DIR="/opt/sentrog"
DATA_DIR="/var/lib/sentrog"
CONFIG_DIR="/etc/sentrog"
ARCH="$(dpkg --print-architecture)"
if [[ "$ARCH" != "arm64" ]]; then
  echo "This installer requires 64-bit Raspberry Pi OS (arm64). Detected: $ARCH" >&2
  exit 1
fi
sudo apt-get update
sudo apt-get install -y curl jq unzip ca-certificates python3-tk fonts-noto-color-emoji libgl1 libglib2.0-0
sudo install -d -m 0755 "$APP_DIR" "$DATA_DIR" "$CONFIG_DIR"
sudo chown -R root:root "$APP_DIR"
sudo chown -R "$USER":"$USER" "$DATA_DIR"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
API="https://api.github.com/repos/$REPO/releases/latest"
URL="$(curl -fsSL "$API" | jq -r '.assets[] | select(.name=="SentroGinhawa-RaspberryPi5-ARM64.zip") | .browser_download_url' | head -n1)"
if [[ -z "$URL" || "$URL" == "null" ]]; then
  echo "No published Raspberry Pi release found. Publish a v* tag/release first." >&2
  exit 1
fi
curl -fL "$URL" -o "$TMP/app.zip"
unzip -q "$TMP/app.zip" -d "$TMP/unpacked"
test -x "$TMP/unpacked/SentroGinhawa/SentroGinhawa"
sudo rm -rf "$APP_DIR/current.new"
sudo mkdir -p "$APP_DIR/current.new"
sudo cp -a "$TMP/unpacked/SentroGinhawa/." "$APP_DIR/current.new/"
sudo rm -rf "$APP_DIR/previous"
if [[ -d "$APP_DIR/current" ]]; then sudo mv "$APP_DIR/current" "$APP_DIR/previous"; fi
sudo mv "$APP_DIR/current.new" "$APP_DIR/current"
sudo tee /usr/local/bin/sentrog-kiosk >/dev/null <<'EOF'
#!/usr/bin/env bash
exec /opt/sentrog/current/SentroGinhawa/SentroGinhawa "$@"
EOF
sudo chmod 0755 /usr/local/bin/sentrog-kiosk
sudo tee /etc/systemd/system/sentrog-kiosk.service >/dev/null <<'EOF'
[Unit]
Description=Sentro Ginhawa Health Kiosk
After=graphical.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=%i
EnvironmentFile=-/etc/sentrog/kiosk.env
WorkingDirectory=/var/lib/sentrog
ExecStartPre=/usr/local/bin/sentrog-update-check
ExecStart=/usr/local/bin/sentrog-kiosk
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical.target
EOF
sudo tee /usr/local/bin/sentrog-update-check >/dev/null <<'EOF'
#!/usr/bin/env bash
# Best-effort startup update check. Keeps current version if network/release unavailable.
set -euo pipefail
REPO="karlnsp18-byte/SentroG"
APP_DIR="/opt/sentrog"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
API="https://api.github.com/repos/$REPO/releases/latest"
URL="$(curl --connect-timeout 5 --max-time 20 -fsSL "$API" | jq -r '.assets[] | select(.name=="SentroGinhawa-RaspberryPi5-ARM64.zip") | .browser_download_url' | head -n1 || true)"
[[ -n "$URL" && "$URL" != "null" ]] || exit 0
curl --connect-timeout 5 --max-time 120 -fL "$URL" -o "$TMP/app.zip" || exit 0
unzip -q "$TMP/app.zip" -d "$TMP/unpacked" || exit 0
NEW="$TMP/unpacked/SentroGinhawa/SentroGinhawa"
OLD="$APP_DIR/current/SentroGinhawa/SentroGinhawa"
[[ -x "$NEW" ]] || exit 0
NEW_HASH="$(sha256sum "$NEW" | cut -d' ' -f1)"
OLD_HASH=""
[[ -f "$OLD" ]] && OLD_HASH="$(sha256sum "$OLD" | cut -d' ' -f1)"
[[ "$NEW_HASH" != "$OLD_HASH" ]] || exit 0
sudo rm -rf "$APP_DIR/current.new"
sudo mkdir -p "$APP_DIR/current.new"
sudo cp -a "$TMP/unpacked/SentroGinhawa/." "$APP_DIR/current.new/"
sudo rm -rf "$APP_DIR/previous"
[[ ! -d "$APP_DIR/current" ]] || sudo mv "$APP_DIR/current" "$APP_DIR/previous"
sudo mv "$APP_DIR/current.new" "$APP_DIR/current"
EOF
sudo chmod 0755 /usr/local/bin/sentrog-update-check
echo "Installed. Configure /etc/sentrog/kiosk.env and test the kiosk before enabling autostart."
echo "For graphical auto-start, create a desktop session autostart entry for /usr/local/bin/sentrog-kiosk."
