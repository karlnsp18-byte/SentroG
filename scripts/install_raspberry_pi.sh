#!/usr/bin/env bash
set -euo pipefail
REPO_URL="${SENTROG_REPO_URL:-https://github.com/karlnsp18-byte/SentroG.git}"
INSTALL_DIR="${SENTROG_INSTALL_DIR:-$HOME/SentroG}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sentrog"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sentrog"
if ! command -v apt-get >/dev/null 2>&1; then echo 'Requires Raspberry Pi OS / Debian with apt-get.' >&2; exit 1; fi
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip python3-tk python3-dev build-essential git python3-opencv libgl1 libglib2.0-0 libatlas-base-dev libjpeg-dev zlib1g-dev
if [[ -d "$INSTALL_DIR/.git" ]]; then git -C "$INSTALL_DIR" fetch origin; git -C "$INSTALL_DIR" pull --ff-only; elif [[ -e "$INSTALL_DIR" ]]; then echo "$INSTALL_DIR exists but is not a Git checkout." >&2; exit 1; else git clone "$REPO_URL" "$INSTALL_DIR"; fi
mkdir -p "$CONFIG_DIR" "$DATA_DIR"; chmod 700 "$CONFIG_DIR" "$DATA_DIR"
if [[ ! -f "$CONFIG_DIR/.env" ]]; then install -m 600 "$INSTALL_DIR/.env.example" "$CONFIG_DIR/.env"; echo "Edit $CONFIG_DIR/.env with local development credentials."; fi
python3 -m venv --system-site-packages "$INSTALL_DIR/.venv"
"$INSTALL_DIR/.venv/bin/python" -m pip install --upgrade pip wheel
"$INSTALL_DIR/.venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"
"$INSTALL_DIR/.venv/bin/pyinstaller" --clean --noconfirm --onefile --name sentrog-kiosk --collect-all cv2 --collect-all PIL "$INSTALL_DIR/kiosk/sentro_ginhawa.py"
echo "Install complete. Configure $CONFIG_DIR/.env, then run $INSTALL_DIR/run.sh"
