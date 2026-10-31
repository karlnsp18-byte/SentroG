#!/usr/bin/env bash
set -euo pipefail
REPO="karlnsp18-byte/SentroG"
APP_DIR="$HOME/.local/opt/sentrog"
DATA_DIR="$HOME/.local/share/sentrog"
CONFIG_DIR="$HOME/.config/sentrog"
ARCH="$(dpkg --print-architecture)"
if [[ "$ARCH" != "arm64" ]]; then
  echo "Requires 64-bit Raspberry Pi OS (arm64). Detected: $ARCH" >&2; exit 1
fi
sudo apt-get update
sudo apt-get install -y curl jq unzip ca-certificates python3-tk fonts-noto-color-emoji libgl1 libglib2.0-0
mkdir -p "$APP_DIR" "$DATA_DIR" "$CONFIG_DIR"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
API="https://api.github.com/repos/$REPO/releases/latest"
URL="$(curl -fsSL "$API" | jq -r '.assets[] | select(.name=="SentroGinhawa-RaspberryPi5-ARM64.zip") | .browser_download_url' | head -n1)"
if [[ -z "$URL" || "$URL" == "null" ]]; then
  echo "No published release yet. Publish a v* tag in GitHub first; then rerun." >&2; exit 1
fi
curl -fL "$URL" -o "$TMP/app.zip"
unzip -q "$TMP/app.zip" -d "$TMP/unpacked"
test -x "$TMP/unpacked/SentroGinhawa/SentroGinhawa"
rm -rf "$APP_DIR/current.new"; mkdir -p "$APP_DIR/current.new"
cp -a "$TMP/unpacked/SentroGinhawa/." "$APP_DIR/current.new/"
rm -rf "$APP_DIR/previous"
[[ ! -d "$APP_DIR/current" ]] || mv "$APP_DIR/current" "$APP_DIR/previous"
mv "$APP_DIR/current.new" "$APP_DIR/current"
cat > "$CONFIG_DIR/kiosk.env.example" <<'EOF'
# Copy values to kiosk.env. Never put real credentials in Git.
SENTRO_TZ_OFFSET=8
IDLE_LOGOUT_SECONDS=90
# SENTRO_FIREBASE_KEY=/absolute/path/to/firebase-service-account.json
EOF
if [[ ! -f "$CONFIG_DIR/kiosk.env" ]]; then cp "$CONFIG_DIR/kiosk.env.example" "$CONFIG_DIR/kiosk.env"; chmod 600 "$CONFIG_DIR/kiosk.env"; fi
cat > "$HOME/.local/bin/sentrog-update-check" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
REPO="karlnsp18-byte/SentroG"
APP_DIR="$HOME/.local/opt/sentrog"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
URL="$(curl --connect-timeout 5 --max-time 20 -fsSL "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.assets[] | select(.name=="SentroGinhawa-RaspberryPi5-ARM64.zip") | .browser_download_url' | head -n1 || true)"
[[ -n "$URL" && "$URL" != "null" ]] || exit 0
curl --connect-timeout 5 --max-time 120 -fL "$URL" -o "$TMP/app.zip" || exit 0
unzip -q "$TMP/app.zip" -d "$TMP/unpacked" || exit 0
NEW="$TMP/unpacked/SentroGinhawa/SentroGinhawa"
OLD="$APP_DIR/current/SentroGinhawa"
[[ -x "$NEW" ]] || exit 0
NEW_HASH="$(sha256sum "$NEW" | cut -d' ' -f1)"
OLD_HASH=""; [[ -f "$OLD" ]] && OLD_HASH="$(sha256sum "$OLD" | cut -d' ' -f1)"
[[ "$NEW_HASH" != "$OLD_HASH" ]] || exit 0
rm -rf "$APP_DIR/current.new"; mkdir -p "$APP_DIR/current.new"
cp -a "$TMP/unpacked/SentroGinhawa/." "$APP_DIR/current.new/"
rm -rf "$APP_DIR/previous"
[[ ! -d "$APP_DIR/current" ]] || mv "$APP_DIR/current" "$APP_DIR/previous"
mv "$APP_DIR/current.new" "$APP_DIR/current"
EOF
mkdir -p "$HOME/.local/bin"
chmod 0755 "$HOME/.local/bin/sentrog-update-check"
cat > "$HOME/.local/bin/sentrog-kiosk" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
CONFIG="$HOME/.config/sentrog/kiosk.env"
if [[ -f "$CONFIG" ]]; then set -a; source "$CONFIG"; set +a; fi
"$HOME/.local/bin/sentrog-update-check" || true
exec "$HOME/.local/opt/sentrog/current/SentroGinhawa" "$@"
EOF
chmod 0755 "$HOME/.local/bin/sentrog-kiosk"
mkdir -p "$HOME/.config/autostart"
cat > "$HOME/.config/autostart/sentrog-kiosk.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Sentro Ginhawa Kiosk
Exec=$HOME/.local/bin/sentrog-kiosk
X-GNOME-Autostart-enabled=true
EOF
echo "Installed. Edit $CONFIG_DIR/kiosk.env, then log out/in or reboot. Test all peripherals and Firebase sync."
