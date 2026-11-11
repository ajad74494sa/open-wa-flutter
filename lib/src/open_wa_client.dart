import 'config/open_wa_config.dart';
import 'core/http_client.dart';
import 'services/api_endpoint_service.dart';
import 'services/catalog_service.dart';
import 'services/chat_service.dart';
import 'services/contact_service.dart';
import 'services/group_service.dart';
import 'services/label_service.dart';
import 'services/media_service.dart';
import 'services/message_service.dart';
import 'services/profile_service.dart';
import 'services/session_service.dart';
import 'services/system_service.dart';
import 'services/webhook_service.dart';

/// Central Facade client for OpenWA API.
///
/// Gives unified access to all 24 API endpoint modules including Sessions,
/// Messages, Contacts, Groups, Webhooks, Labels, Catalog, Media, Profile, and System metrics.
class OpenWaClient {
  final OpenWaConfig config;
  final OpenWaHttpClient _httpClient;

  /// Service for Managing WhatsApp Sessions (Create, QR, Lifecycle).
  late final SessionService sessions;

  /// Generic dispatcher for every operation in the official OpenWA catalog.
  late final OpenWaApiService api;

  /// Session-scoped chat list and chat action operations.
  late final ChatService chats;

  /// Service for Sending/Receiving Messages (Text, Media, Location, Buttons, Actions).
  late final MessageService messages;

  /// Service for Managing Contacts & Checking Number Status.
  late final ContactService contacts;

  /// Service for Group Management & Participant Admin Actions.
  late final GroupService groups;

  /// Service for Webhook Registration & Signature Verification.
  late final WebhookService webhooks;

  /// Service for WhatsApp Business Labels.
  late final LabelService labels;

  /// Service for WhatsApp Business Catalog & Products.
  late final CatalogService catalog;

  /// Service for Media Uploads & Decryption.
  late final MediaService media;

  /// Service for Profile Settings (Name, Status, Picture).
  late final ProfileService profile;

  /// Service for System Health, Statistics, Metrics & Audit Logs.
  late final SystemService system;

  OpenWaClient(this.config, {OpenWaHttpClient? httpClient})
      : _httpClient = httpClient ?? OpenWaHttpClient(config) {
    api = OpenWaApiService(_httpClient);
    sessions = SessionService(_httpClient);
    chats = ChatService(_httpClient);
    messages = MessageService(_httpClient);
    contacts = ContactService(_httpClient);
    groups = GroupService(_httpClient);
    webhooks = WebhookService(_httpClient);
    labels = LabelService(_httpClient);
    catalog = CatalogService(_httpClient);
    media = MediaService(_httpClient);
    profile = ProfileService(_httpClient);
    system = SystemService(_httpClient);
  }

  /// Convenience factory for creating client from raw params with HTTPS enforcement.
  factory OpenWaClient.create({
    required String baseUrl,
    required String apiKey,
    String? webhookSecret,
    Duration timeout = const Duration(seconds: 30),
    int maxRetries = 3,
    bool requireHttps = true,
  }) {
    final config = OpenWaConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      webhookSecret: webhookSecret,
      timeout: timeout,
      maxRetries: maxRetries,
      requireHttps: requireHttps,
    );
    return OpenWaClient(config);
  }

  /// Safely closes underlying HTTP connections and releases network resources.
  void close() {
    _httpClient.close();
  }
}
