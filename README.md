# DeepSeek Balance

A minimal, polished and lightweight Flutter utility to instantly check your
**DeepSeek API balance** from a secure, on-device API key.

<p align="center">
  <img src="screen/screen%2001.jpg" alt="DeepSeek Balance app screenshot" width="340"/>
</p>

## Features

- **API key entry** with show/hide toggle and animated save action.
- **Secure storage** of the key via `flutter_secure_storage` (Keychain / Keystore).
  The balance refreshes automatically on launch when a key is present.
- **Cute balance card** with a large, currency-formatted total and an
  `Active` / `Unavailable` status badge.
- **Color-coded traffic indicator**:
  - 🔴 **Red** – peak hours (higher usage / latency)
  - 🟢 **Green** – off-peak hours
- **Breakdown rows** for *Topped-up* and *Granted / Bonus* amounts.
- **Swipe-to-refresh**, custom brand loader and friendly error states.
- **Dynamic theme**: clean light mode and a deep, refined dark mode.

## Peak / off-peak logic

DeepSeek's schedule is defined in **Beijing time (UTC+8)**:

- Peak windows: **09:00–12:00** and **14:00–18:00**
- **Weekends (Saturday & Sunday) are always off-peak**
- Everything else is off-peak

The service converts this to the device's local timezone and computes the next
switch automatically (`lib/services/peak_hours_service.dart`).

## Tech stack

| Concern         | Choice                                  |
| --------------- | --------------------------------------- |
| Framework       | Flutter 3.x / Dart 3                    |
| State management| `provider` (`ChangeNotifier`)           |
| Storage         | `flutter_secure_storage`                |
| Networking      | `http`                                  |
| Formatting      | `intl`                                  |

## API

```
GET https://api.deepseek.com/user/balance
Authorization: Bearer <DEEPSEEK_API_KEY>
Accept: application/json
```

Example response:

```json
{
  "is_available": true,
  "balance_infos": [
    {
      "currency": "USD",
      "total_balance": "10.00",
      "granted_balance": "0.00",
      "topped_up_balance": "10.00"
    }
  ]
}
```

## Getting started

```bash
flutter pub get
flutter run
```

Requirements: Flutter 3.x+. Android needs the `INTERNET` permission (already
declared in `AndroidManifest.xml`); iOS uses the keychain for secure storage.

## Project structure

```
lib/
├── main.dart                     # Entry point
├── app.dart                      # MaterialApp + providers
├── models/                       # Balance response models
│   ├── balance_info.dart
│   └── balance_response.dart
├── services/
│   ├── api_service.dart          # DeepSeek REST client
│   ├── secure_storage_service.dart
│   └── peak_hours_service.dart   # Peak / off-peak logic
├── providers/
│   └── balance_provider.dart     # Single source of truth
├── screens/
│   └── home_screen.dart
├── theme/
│   └── app_theme.dart
├── utils/
│   └── formatters.dart
└── widgets/                      # Reusable UI components
```

## App icon

The launcher icons are generated programmatically from the brand whale mark:

```bash
dart run tool/generate_icon.dart        # writes assets/icon/*.png
dart run flutter_launcher_icons         # applies to Android & iOS
```

## Tests

```bash
flutter test
flutter analyze
```
