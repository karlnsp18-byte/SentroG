#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sentrog"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/sentrog"
VENV="$ROOT/.venv"; BIN="$ROOT/dist/sentrog-kiosk"
mkdir -p "$CONFIG_DIR" "$DATA_DIR"; chmod 700 "$CONFIG_DIR" "$DATA_DIR"
export SENTRO_CONFIG_DIR="$CONFIG_DIR" SENTRO_DATA_DIR="$DATA_DIR"
if [[ -f "$CONFIG_DIR/.env" ]]; then set -a; source "$CONFIG_DIR/.env"; set +a; fi
if [[ "${SENTRO_AUTO_UPDATE:-1}" != 0 && -d "$ROOT/.git" ]]; then
  BEFORE="$(git -C "$ROOT" rev-parse HEAD)"
  if git -C "$ROOT" diff --quiet && git -C "$ROOT" diff --cached --quiet; then
    if git -C "$ROOT" fetch --quiet origin main; then
      REMOTE="$(git -C "$ROOT" rev-parse origin/main)"
      if [[ "$BEFORE" != "$REMOTE" ]]; then
        git -C "$ROOT" merge --ff-only --quiet origin/main
        "$VENV/bin/pip" install -r "$ROOT/requirements.txt"
        "$VENV/bin/pyinstaller" --clean --noconfirm --onefile --name sentrog-kiosk --collect-all cv2 --collect-all PIL "$ROOT/kiosk/sentro_ginhawa.py"
      fi
    else echo 'Update check failed; starting current installed version.' >&2; fi
  else echo 'Local changes detected; skipping auto-update.' >&2; fi
fi
if [[ ! -x "$BIN" ]]; then echo 'Executable missing. Run scripts/install_raspberry_pi.sh after application source is present.' >&2; exit 1; fi
exec "$BIN" "$@"
