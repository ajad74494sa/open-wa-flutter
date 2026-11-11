# OpenWA Flutter Client SDK & App

A 100% secure, enterprise-grade, A-to-Z implementation of the [OpenWA API Reference](https://docs.open-wa.org/api-reference) built in Dart & Flutter.

---

## 🛠️ Environment Setup & Prerequisites

### 1. Flutter SDK Version
- **Flutter SDK:** `>= 3.13.0` (Dart SDK `^3.13.7` or higher)
- Verify your Flutter version by running:
  ```bash
  flutter --version
  ```

### 2. Platform Requirements
- **macOS:** macOS 12+ (for macOS Desktop target)
- **Android:** Android SDK API level 21 or higher (for Android target)
- **iOS:** iOS 12+ (for iOS target)

---

## 🚀 Running the Project Locally

### Step 1: Clone the Repository
```bash
git clone https://github.com/ajad74494sa/open-wa-flutter.git
cd open-wa-flutter
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure Your Environment / Credentials
Open `lib/main.dart` and ensure your OpenWA server Base URL and API Key are configured in the controllers:
```dart
final _baseUrlController = TextEditingController(text: 'https://w.kheyalcafe.com');
final _apiKeyController = TextEditingController(text: 'YOUR_API_KEY');
```

### Step 4: Run Unit Tests
Verify all SDK security checks, data models, and HMAC validations pass:
```bash
flutter test
```

### Step 5: Run the App
- **Run on macOS Desktop:**
  ```bash
  flutter run -d macos
  ```
- **Run on Connected Android Device / Emulator:**
  ```bash
  flutter run -d android
  ```
- **Run on iOS Simulator:**
  ```bash
  flutter run -d ios
  ```

---

## 🏗️ Architecture & Project Structure

The SDK is built using **Clean Architecture** principles, enforcing separation of concerns, immutability, and robust type safety across all layers:

```
lib/
├── open_wa.dart                          # Public library exports
├── main.dart                             # Interactive Flutter Demo UI
└── src/
    ├── config/
    │   └── open_wa_config.dart           # Immutable configuration & HTTPS validation
    ├── core/
    │   ├── api_response.dart             # Generic typed API response wrapper
    │   ├── exceptions.dart               # Typed exceptions (AuthenticationException, RateLimitException, etc.)
    │   ├── http_client.dart              # Secure HTTP client with auth headers, retries & exponential backoff
    │   └── security_utils.dart           # HMAC SHA-256 webhook verification & log sanitization
    ├── models/                           # Strongly-typed immutable JSON models
    │   ├── catalog_models.dart           # Product & Catalog models
    │   ├── contact_models.dart           # Contact & Number Status models
    │   ├── group_models.dart             # Group Metadata & Participant models
    │   ├── label_models.dart             # Label & Color models
    │   ├── media_models.dart             # Media upload/decryption models
    │   ├── message_models.dart           # ChatMessage, Requests & MessageType enums
    │   ├── session_models.dart           # SessionInfo, QR Code & SessionStatus enums
    │   ├── system_models.dart            # Server Health & Performance Metrics models
    │   └── webhook_models.dart           # WebhookConfig & Payload models
    └── services/                         # Service modules covering all OpenWA API endpoints
        ├── catalog_service.dart          # Catalog & Product management
        ├── contact_service.dart          # Contacts & Number status check
        ├── group_service.dart            # Group creation, admin controls & invite links
        ├── label_service.dart            # Business chat labels
        ├── media_service.dart            # Media upload & decryption
        ├── message_service.dart          # Text, Media, Voice, Location, Buttons & Chat actions
        ├── profile_service.dart          # Profile name, status & picture
        ├── session_service.dart          # Session lifecycle, auth check & QR code
        ├── system_service.dart           # Server Health, Metrics & Audit logs
        └── webhook_service.dart          # Webhook registration & signature verification
```

---

## 🔒 100% Security Features

1. **Authentication**: Header-based `Authorization: Bearer <apiKey>` and `api_key: <apiKey>` injection.
2. **Webhook Security**: HMAC-SHA256 signature verification with constant-time string comparison (`timingSafeEqual`) to prevent timing side-channel attacks.
3. **Log Sanitization**: `SecurityUtils.sanitizeLog()` automatically redacts sensitive bearer tokens and API keys from outputs and crash logs.
4. **HTTPS Enforcement**: Strict HTTPS validation option (`requireHttps: true`).
5. **Transient Resilience**: Exponential backoff retry mechanism for network timeouts and server errors (500/502/503/504).

---

## 📦 Covered API Modules (24 Categories)

- **Sessions**: Start, stop, restart, QR pairing, logout, kill, list sessions, auth status check.
- **Messages**: Send text, images, video, voice (PTT), files/documents, stickers, locations, contacts, buttons, retrieve history, reply, forward, star, delete, clear chats.
- **Contacts**: List contacts, get contact details, number registration check (`checkNumberStatus`), block/unblock, profile pictures.
- **Groups**: Create group, get metadata, add/remove participants, promote/demote admins, get/revoke invite links, join via invite, leave group, update title, description, and icon photo.
- **Webhooks**: Register webhooks, unregister, list webhooks, HMAC signature verification.
- **Labels**: Manage WhatsApp Business labels and assign/remove them from chats.
- **Catalog**: Business product catalog management and product CRUD operations.
- **Media**: Download, decrypt, and upload media assets.
- **Profile**: Set profile name, status message, and profile picture.
- **System**: Server health monitoring, performance metrics, statistics, and audit logs.

---

## 🚀 Quick Start Example

```dart
import 'package:open_wa/open_wa.dart';

void main() async {
  // 1. Initialize Client
  final client = OpenWaClient.create(
    baseUrl: 'https://api.yourdomain.com',
    apiKey: 'YOUR_API_KEY',
    requireHttps: true,
  );

  try {
    // 2. Check Session Status
    final sessionResp = await client.sessions.getSessionInfo('default');
    print('Session Status: ${sessionResp.data?.status}');

    // 3. Send Message
    final msgResp = await client.messages.sendText(
      '1234567890@c.us',
      'Hello from OpenWA Dart SDK!',
    );
    print('Message Sent ID: ${msgResp.data?.id}');
  } on AuthenticationException catch (e) {
    print('Auth failed: ${e.message}');
  } on OpenWaApiException catch (e) {
    print('API Error [${e.statusCode}]: ${e.message}');
  } finally {
    client.close();
  }
}
```
