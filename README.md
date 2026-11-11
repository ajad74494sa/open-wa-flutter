# OpenWA Flutter Client SDK & App

A Dart SDK and chat-first Flutter app for the [OpenWA API](https://docs.open-wa.org/api-reference), including a catalog-backed dispatcher for the official endpoint set.

---

## 🛠️ Environment Setup & Prerequisites

### 1. Flutter SDK Version
- **Flutter SDK:** `>= 3.47.9` (Dart SDK `^3.13.7` or higher)
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

### Step 3: Connect to OpenWA
Run the app and enter your OpenWA server URL and API key on the connection screen.
Credentials are not stored in source code. After connecting, select or create a
WhatsApp session for chats, or open the Developer Console to inspect and call any
operation in the endpoint catalog. Mutating requests require confirmation.

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
    │   ├── api_endpoint_catalog.dart     # Official OpenWA endpoint catalog
    │   ├── catalog_models.dart           # Product & Catalog models
    │   ├── contact_models.dart           # Contact & Number Status models
    │   ├── group_models.dart             # Group Metadata & Participant models
    │   ├── label_models.dart             # Label & Color models
    │   ├── media_models.dart             # Media upload/decryption models
    │   ├── message_models.dart           # ChatMessage, Requests & MessageType enums
    │   ├── session_models.dart           # SessionInfo, QR Code & SessionStatus enums
    │   ├── system_models.dart            # Server Health & Performance Metrics models
    │   └── webhook_models.dart           # WebhookConfig & Payload models
    └── services/                         # Typed services plus catalog dispatcher
        ├── api_endpoint_service.dart     # Generic dispatcher for all catalog operations
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

## Security and reliability

1. **Authentication**: OpenWA API keys are sent using the `X-API-Key` header.
2. **Webhook Security**: HMAC-SHA256 signature verification with constant-time string comparison (`timingSafeEqual`) to prevent timing side-channel attacks.
3. **Log Sanitization**: `SecurityUtils.sanitizeLog()` automatically redacts sensitive bearer tokens and API keys from outputs and crash logs.
4. **HTTPS Enforcement**: Strict HTTPS validation option (`requireHttps: true`).
5. **Transient Resilience**: Exponential backoff retry mechanism for network timeouts and server errors (500/502/503/504).

---

## API endpoint coverage

The endpoint catalog is generated from the official OpenWA OpenAPI 0.30.0
specification and contains 206 operations across 24 modules. Use
`client.api.invoke(operationId, ...)` for any catalog operation or the app's
Developer Console for interactive requests.

The full route-by-route checklist is in
[docs/API_ENDPOINT_COVERAGE.md](./docs/API_ENDPOINT_COVERAGE.md). Automated tests
verify that every operation dispatches its documented method and route to a mock
server. This does not confirm that a particular deployment enables an endpoint
or that the current key/session has permission. Live verification is not claimed
unless run against a configured server.
Existing typed service methods are convenience wrappers and are not generated
from the 0.30.0 specification; use the catalog dispatcher when you need the
exact documented route and request contract.

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
    // Call any documented operation by its OpenAPI operation ID.
    final apiResponse = await client.api.invoke('SessionController_findAll');
    print('Sessions response: ${apiResponse.data}');

    // 2. List sessions and use the UUID returned by the API
    final sessionsResp = await client.sessions.listSessions();
    final sessions = sessionsResp.data;
    if (sessions == null || sessions.isEmpty) {
      throw StateError('No sessions are available for this API key.');
    }

    final sessionId = sessions.first.sessionId;
    final sessionResp = await client.sessions.getSessionInfo(sessionId);
    print('Session Status: ${sessionResp.data?.status}');

    // 3. Send Message
    final msgResp = await client.messages.sendText(
      '1234567890@c.us',
      'Hello from OpenWA Dart SDK!',
      sessionId: sessionId,
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
