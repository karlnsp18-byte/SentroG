#!/usr/bin/env bash
set -u
echo "=== Sentro Ginhawa Raspberry Pi hardware diagnostics ==="
echo "Date: $(date -Is)"
echo "Architecture: $(dpkg --print-architecture 2>/dev/null || uname -m)"
echo
echo "--- USB / serial devices ---"
if command -v lsusb >/dev/null 2>&1; then lsusb; else echo "lsusb not installed (sudo apt install usbutils)"; fi
echo
echo "--- Serial ports ---"
shopt -s nullglob
ports=(/dev/ttyUSB* /dev/ttyACM* /dev/serial/by-id/*)
if (("${#ports[@]}" == 0)); then echo "No USB serial ports found."; else printf '%s\n' "${ports[@]}"; fi
echo
echo "--- Camera devices ---"
ls -l /dev/video* 2>/dev/null || echo "No /dev/video* device found."
if command -v rpicam-hello >/dev/null 2>&1; then
  echo "Camera utility: rpicam-hello available"
elif command -v libcamera-hello >/dev/null 2>&1; then
  echo "Camera utility: libcamera-hello available"
else
  echo "No Raspberry Pi camera test utility found; USB webcam may still work via OpenCV."
fi
echo
echo "--- Printer ---"
if command -v lpstat >/dev/null 2>&1; then lpstat -p -d 2>&1 || true; else echo "CUPS tools not installed (sudo apt install cups cups-client)"; fi
echo
echo "--- Network ---"
if command -v nmcli >/dev/null 2>&1; then nmcli -t -f DEVICE,TYPE,STATE device status; else ip -brief link 2>/dev/null || true; fi
echo
echo "--- Python modules ---"
python3 - <<'PY'
for name in ("serial", "cv2", "PIL", "firebase_admin", "reportlab"):
    try:
        mod = __import__(name)
        print(f"{name}: available ({getattr(mod, '__version__', 'version unknown')})")
    except Exception as e:
        print(f"{name}: NOT available ({e})")
PY
echo
echo "NOTE: Device presence is not proof that a sensor is calibrated or returning valid measurements."
