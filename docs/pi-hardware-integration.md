# Raspberry Pi 5 hardware plan — confirmed vs not yet integrated

Target environment supplied by project owner: Raspberry Pi OS 64-bit Desktop, Wi-Fi, blood pressure monitor, digital thermometer, weighing scale, blood glucose meter, QR camera/scanner and thermal printer.

## What the current kiosk source actually does

The uploaded `APP/sentro_ginhawa_refined.py` contains an Arduino serial reader for:
- `TEMP:<celsius>` (accepted range 30–45 °C)
- `DIST:<centimetres>` (used to calculate height from a configured sensor-to-floor mounting distance)

It samples temperature and height from that serial protocol. The source explicitly labels blood pressure, glucose and weight as simulated values in `read_sensor()`. Do not use those simulated values for health records or live users. Height is only real if the correct VL53L1X distance sensor and Arduino firmware are installed and calibrated. The current source does not demonstrate a verified thermometer model or clinical-grade temperature probe.

Other current code paths:
- QR: OpenCV camera capture and QRCodeDetector; camera index and permissions must be tested on the Pi.
- Printing: generates a PDF and opens it with the OS PDF viewer. This is not yet a verified direct thermal-printer integration.
- BP, glucose and weight: no device-specific serial/Bluetooth/USB driver yet.
- Lancet dispenser: simulated stub; do not actuate hardware based on the stub.

## Required device inventory before writing drivers

For each device, record:
- manufacturer and exact model
- connection: USB, USB serial, Bluetooth, GPIO, or other
- communication specification / SDK / protocol supplied by manufacturer
- output units and resolution
- calibration certificate or validation method
- whether the device is intended for clinical use and its regulatory status

Never infer a protocol from a generic device category. Many consumer BP monitors and glucose meters do not expose readings over USB/Bluetooth, or require vendor-specific pairing and SDKs.

## Integration plan

| Device | Current project state | Next engineering step |
|---|---|---|
| Blood pressure | Simulated in source | Obtain model/protocol; implement validated parser or manual entry; preserve systolic and diastolic separately |
| Digital thermometer | Generic Arduino TEMP serial channel | Confirm exact sensor/probe, calibration and whether its readings are body temperature; validate against reference |
| Height | Arduino DIST channel + configured mount height | Confirm VL53L1X/Arduino hardware and firmware; measure mount height; test with reference stadiometer |
| Weighing scale | Simulated in source | Obtain scale model and protocol; add stable-weight detection, tare and units |
| BMI | Calculated in kiosk | Calculate from paired height (cm) and weight (kg); store source measurement IDs and formula version |
| Blood glucose | Simulated in source | Obtain meter model/protocol; capture value, unit, timestamp and fasting/pre/post-meal/random context |
| QR camera | OpenCV camera index | Test the actual USB/CSI camera, focus, permissions and QR payload format |
| Thermal printer | PDF opened in viewer | Identify printer model, paper width, USB/network/Bluetooth interface; add CUPS or ESC/POS driver and print test |

## Safe integration requirements

- Keep device acquisition behind one adapter per hardware model; never assume every device speaks a shared serial protocol.
- Mark all simulated/demo values as TEST DATA and prevent them from being saved as real measurements. Remove the random BP/glucose/weight generator before any deployment with residents.
- Record device model, device identifier, operator/kiosk ID, units, measurement context, timestamps and calibration/validation status.
- Validate range and format, but do not silently alter readings. Preserve the raw device response for troubleshooting where appropriate and privacy-approved.
- Keep the kiosk operational offline: local durable database/outbox first, cloud sync second.
- Do not upload personal data or service-account secrets to GitHub.
- Do not use the current name-based QR identity as the long-term security boundary. Move to an opaque, revocable resident token and authenticated kiosk/device registration.
- Health data are sensitive personal data. Confirm consent, retention, access control, audit, breach response and applicable Philippine Data Privacy Act obligations with the responsible organization.

## Run discovery on the Pi

From the repository root:
```bash
chmod +x scripts/diagnose_pi_hardware.sh
./scripts/diagnose_pi_hardware.sh
```

Send the complete output plus the exact device model numbers. Do not post serial numbers, resident records, Wi-Fi passwords or Firebase credentials.
