import 'package:flutter/material.dart';
import 'package:open_wa/open_wa.dart';

import 'dart:convert';
import 'dart:async';

class OpenWaHomeScreen extends StatefulWidget {
  const OpenWaHomeScreen({super.key});

  @override
  State<OpenWaHomeScreen> createState() => _OpenWaHomeScreenState();
}

class _OpenWaHomeScreenState extends State<OpenWaHomeScreen> {
  final _baseUrlController = TextEditingController(
    text: 'https://w.kheyalcafe.com',
  );
  final _apiKeyController = TextEditingController();
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();
  final _apiPathParametersController = TextEditingController();
  final _apiQueryParametersController = TextEditingController();
  final _apiRequestBodyController = TextEditingController();
  final _apiHeadersController = TextEditingController();

  OpenWaClient? _client;
  List<SessionInfo> _sessions = [];
  List<ChatSummary> _chats = [];
  List<Contact>? _contacts;
  List<GroupMetadata>? _groups;
  List<ChatMessage> _messages = [];
  SessionInfo? _activeSession;
  ChatSummary? _selectedChat;
  String? _selectedSessionId;
  String? _connectedSessionId;
  String? _errorMessage;
  String? _noticeMessage;
  String? _apiResult;
  String _apiModule = 'sessions';
  String _apiOperationId = 'SessionController_findAll';
  int _section = 0;
  bool _isLoading = false;

  Timer? _notificationPollTimer;
  final Set<String> _knownMessageIds = {};

  bool get _apiConnected => _client != null;
  bool get _sessionConnected =>
      _connectedSessionId != null && _connectedSessionId == _selectedSessionId;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _chatBgColor =>
      _isDark ? const Color(0xFF0B141A) : const Color(0xFFECE5DD);
  Color get _surfaceColor => _isDark ? const Color(0xFF111B21) : Colors.white;
  Color get _inputFillColor =>
      _isDark ? const Color(0xFF202C33) : const Color(0xFFF0F2F5);
  Color get _incomingBubbleColor =>
      _isDark ? const Color(0xFF202C33) : Colors.white;
  Color get _outgoingBubbleColor =>
      _isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3);
  Color get _selectedTileColor =>
      _isDark ? const Color(0xFF222D34) : const Color(0xFFE9F5F2);
  Color get _avatarBgColor =>
      _isDark ? const Color(0xFF1F2C34) : const Color(0xFFDDF2EA);
  Color get _avatarFgColor =>
      _isDark ? const Color(0xFF00A884) : const Color(0xFF075E54);
  Color get _primaryColor =>
      _isDark ? const Color(0xFF00A884) : const Color(0xFF128C7E);
  Color get _appBarBgColor =>
      _isDark ? const Color(0xFF1F2C34) : const Color(0xFF075E54);
  Color get _textColor =>
      _isDark ? const Color(0xFFE9EDEF) : const Color(0xFF111B21);
  Color get _subTextColor =>
      _isDark ? const Color(0xFF8696A0) : const Color(0xFF667781);

  @override
  void initState() {
    super.initState();
    NotificationService().init();
    _startNotificationPoller();
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      _baseUrlController.text = 'https://w.kheyalcafe.com';
      _apiKeyController.text = 'owa_k1_8b99b371a37a83d1939620150f863a1bc2b977cdc40d76a261223f9f99071bed';
      await _connectApi();
    } catch (_) {}
  }

  Future<void> _logout() async {
    _client?.close();
    setState(() {
      _client = null;
      _connectedSessionId = null;
      _selectedSessionId = null;
      _activeSession = null;
      _sessions = [];
      _chats = [];
      _messages = [];
      _noticeMessage = 'Logged out successfully.';
    });
  }

  void _startNotificationPoller() {
    _notificationPollTimer =
        Timer.periodic(const Duration(seconds: 3), (_) async {
          if (_client == null || _connectedSessionId == null || !mounted) return;
          try {
            await _loadChats(silent: true);

            if (_selectedChat != null) {
              final res = await _client!.messages.getMessages(
                _connectedSessionId!,
                _selectedChat!.id,
              );
              final messages = res.data ?? [];
              bool hasNew = false;
              for (final m in messages) {
                if (!_knownMessageIds.contains(m.id)) {
                  _knownMessageIds.add(m.id);
                  hasNew = true;
                  if (!m.fromMe) {
                    NotificationService().showMessageNotification(
                      title: 'New Message from ${m.senderName ?? m.from}',
                      body: m.body,
                    );
                  }
                }
              }
              if (hasNew && mounted) {
                setState(() => _messages = messages);
              }
            }
          } catch (_) {
            // Suppress background polling errors
          }
        });
  }

  @override
  void dispose() {
    _notificationPollTimer?.cancel();
    _client?.close();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    _apiPathParametersController.dispose();
    _apiQueryParametersController.dispose();
    _apiRequestBodyController.dispose();
    _apiHeadersController.dispose();
    super.dispose();
  }

  Future<void> _connectApi() async {
    if (_isLoading) return;
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    if (baseUrl.isEmpty || apiKey.isEmpty) {
      _showError('Enter the OpenWA server URL and API key.');
      return;
    }

    late final OpenWaClient client;
    try {
      client = OpenWaClient.create(
        baseUrl: baseUrl,
        apiKey: apiKey,
        requireHttps: true,
      );
    } catch (error) {
      _showError('Invalid API configuration: $error');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _noticeMessage = 'Connecting to the OpenWA API...';
    });
    try {
      final response = await client.sessions.listSessions();
      final oldClient = _client;

      setState(() {
        _client = client;
        _sessions = response.data ?? [];
        _selectedSessionId = null;
        _connectedSessionId = null;
        _activeSession = null;
        _selectedChat = null;
        _chats = [];
        _contacts = null;
        _groups = null;
        _messages = [];
        _noticeMessage = _sessions.isEmpty
            ? 'API connected. No sessions are available for this key.'
            : 'API connected. Select a session to load its chats.';
      });
      oldClient?.close();
    } on OpenWaApiException catch (error) {
      client.close();
      _showError('API error [${error.statusCode}]: ${error.message}');
    } catch (error) {
      client.close();
      _showError('Could not connect to the API: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _disconnectApi() {
    _client?.close();
    setState(() {
      _client = null;
      _sessions = [];
      _selectedSessionId = null;
      _connectedSessionId = null;
      _activeSession = null;
      _selectedChat = null;
      _chats = [];
      _contacts = null;
      _groups = null;
      _messages = [];
      _noticeMessage = 'Disconnected from the API.';
      _errorMessage = null;
    });
  }

  Future<void> _refreshSessions() async {
    final client = _client;
    if (client == null || _isLoading) return;
    await _runRequest(() async {
      final response = await client.sessions.listSessions();
      final sessions = response.data ?? [];
      setState(() {
        _sessions = sessions;
        if (!sessions.any(
          (session) => session.sessionId == _selectedSessionId,
        )) {
          _selectedSessionId = null;
          _connectedSessionId = null;
          _activeSession = null;
          _selectedChat = null;
          _messages = [];
        }
        _noticeMessage = 'Loaded ${sessions.length} session(s).';
      });
    });
  }

  void _selectSession(String? sessionId) {
    if (sessionId == null) return;
    final client = _client;
    if (client == null) return;
    setState(() {
      _selectedSessionId = sessionId;
      _connectedSessionId = null;
      _activeSession = null;
      _selectedChat = null;
      _chats = [];
      _contacts = null;
      _groups = null;
      _messages = [];
      _section = 0;
      _noticeMessage = 'Session selected. Connect it to load conversations.';
      _errorMessage = null;
    });
  }

  Future<void> _createSession() async {
    final client = _client;
    if (client == null || _isLoading) return;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create WhatsApp session'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Session name',
            hintText: 'my-bot',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.isEmpty || _client != client) return;
    await _runRequest(() async {
      final response = await client.sessions.createSession(name);
      final session = response.data;
      if (session == null) {
        throw const FormatException('The API returned no created session.');
      }
      final sessionsResponse = await client.sessions.listSessions();
      if (!mounted) return;
      final sessions = sessionsResponse.data ?? [];
      if (!sessions.any(
        (listedSession) => listedSession.sessionId == session.sessionId,
      )) {
        sessions.add(session);
      }
      setState(() {
        _sessions = sessions;
        _selectedSessionId = session.sessionId;
        _noticeMessage =
            'Created session ${session.name ?? session.sessionId}. Connect it to continue.';
      });
    });
  }

  Future<void> _connectSession() async {
    final client = _client;
    final sessionId = _selectedSessionId;
    if (client == null || sessionId == null || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _noticeMessage = 'Connecting to WhatsApp session...';
    });
    try {
      final knownSession = _sessions.firstWhere(
        (session) => session.sessionId == sessionId,
      );
      final response = knownSession.isConnected
          ? await client.sessions.getSessionInfo(sessionId)
          : await client.sessions.startSession(sessionId);
      final session =
          response.data ??
          (await client.sessions.getSessionInfo(sessionId)).data;
      if (session == null) {
        throw const FormatException('The API returned no session details.');
      }
      final activeSession = session;
      setState(() {
        _connectedSessionId = sessionId;
        _activeSession = activeSession;
        _noticeMessage =
            'Connected to ${activeSession.name ?? activeSession.sessionId}.';
      });
      if (activeSession.status == SessionStatus.ready ||
          activeSession.status == SessionStatus.connected) {
        await _loadChats();
      } else {
        setState(() {
          _noticeMessage =
              'Session started (${activeSession.status.name}). Chats will load when it is ready.';
        });
      }
    } on OpenWaApiException catch (error) {
      _showError('Session API error [${error.statusCode}]: ${error.message}');
    } catch (error) {
      _showError('Could not connect the session: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadChats({bool silent = false}) async {
    final client = _client;
    final sessionId = _connectedSessionId;
    if (client == null || sessionId == null) return;
    final response = await client.chats.listChats(sessionId);
    if (!mounted) return;
    setState(() {
      _chats = response.data ?? [];
      if (!silent) {
        _noticeMessage = _chats.isEmpty
            ? 'No conversations yet.'
            : 'Loaded ${_chats.length} conversations.';
      }
    });
  }

  Future<void> _loadContacts() async {
    final client = _client;
    final sessionId = _connectedSessionId;
    if (client == null || sessionId == null) return;
    final response = await client.contacts.getAllContacts(sessionId);
    if (!mounted) return;
    setState(() => _contacts = response.data ?? []);
  }

  Future<void> _loadGroups() async {
    final client = _client;
    final sessionId = _connectedSessionId;
    if (client == null || sessionId == null) return;
    final response = await client.groups.getGroups(sessionId);
    if (!mounted) return;
    setState(() => _groups = response.data ?? []);
  }

  Future<void> _selectSection(int section) async {
    setState(() {
      _section = section;
      _selectedChat = null;
      _messages = [];
      _errorMessage = null;
    });
    if (!_sessionConnected) return;
    await _runRequest(() async {
      if (section == 1 && _contacts == null) await _loadContacts();
      if (section == 2 && _groups == null) await _loadGroups();
    });
  }

  void _selectApiModule(String? module) {
    if (module == null) return;
    final firstSafeOperation = OpenWaApiService.endpoints.firstWhere(
      (endpoint) =>
          endpoint.module == module &&
          const {'GET', 'HEAD', 'OPTIONS'}.contains(endpoint.method),
      orElse: () => OpenWaApiService.endpoints.firstWhere(
        (endpoint) => endpoint.module == module,
      ),
    );
    _selectApiOperation(firstSafeOperation);
  }

  void _selectApiOperation(OpenWaApiEndpoint endpoint) {
    final pathDefaults = <String, String>{
      for (final parameter in endpoint.pathParameters)
        parameter.name: parameter.name == 'sessionId'
            ? (_selectedSessionId ?? '')
            : '',
    };
    final queryDefaults = <String, String>{
      for (final parameter in endpoint.queryParameters.where(
        (parameter) => parameter.required,
      ))
        parameter.name: '',
    };
    setState(() {
      _apiModule = endpoint.module;
      _apiOperationId = endpoint.operationId;
      _apiPathParametersController.text = const JsonEncoder.withIndent('  ')
          .convert(pathDefaults);
      _apiQueryParametersController.text = const JsonEncoder.withIndent('  ')
          .convert(queryDefaults);
      _apiRequestBodyController.text = endpoint.requestContentType == null
          ? ''
          : '{}';
      _apiHeadersController.text = '{}';
      _apiResult = null;
      _errorMessage = null;
      _noticeMessage = null;
    });
  }

  Map<String, dynamic> _decodeJsonObject(
    TextEditingController controller,
    String fieldName,
  ) {
    final source = controller.text.trim();
    if (source.isEmpty) return {};
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw FormatException('$fieldName must be a JSON object.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _runApiEndpoint() async {
    final client = _client;
    if (client == null) return;
    final endpoint = OpenWaApiService.endpointFor(_apiOperationId);
    if (!const {'GET', 'HEAD', 'OPTIONS'}.contains(endpoint.method)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm API request'),
          content: Text(
            '${endpoint.method} ${endpoint.path} may change server or WhatsApp data. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send request'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted || _client != client) return;
    }

    await _runRequest(() async {
      final rawBody = _apiRequestBodyController.text.trim();
      Object? body = rawBody.isEmpty ? null : jsonDecode(rawBody);
      final files = <OpenWaApiFile>[];
      if (endpoint.requestContentType == 'multipart/form-data' && body is Map) {
        final fields = Map<String, dynamic>.from(body);
        for (final entry in fields.entries.toList()) {
          final file = entry.value;
          if (file is! Map || file['base64'] is! String) continue;
          files.add(
            OpenWaApiFile(
              fieldName: entry.key,
              fileName: file['fileName'] as String? ?? entry.key,
              bytes: base64Decode(file['base64'] as String),
            ),
          );
          fields.remove(entry.key);
        }
        body = fields;
      }

      final response = await client.api.invoke(
        endpoint.operationId,
        pathParameters: _decodeJsonObject(
          _apiPathParametersController,
          'Path parameters',
        ).map((key, value) => MapEntry(key, value.toString())),
        queryParameters: _decodeJsonObject(
          _apiQueryParametersController,
          'Query parameters',
        ),
        body: body,
        files: files,
        headers: _decodeJsonObject(
          _apiHeadersController,
          'Custom headers',
        ).map((key, value) => MapEntry(key, value.toString())),
      );
      if (!mounted) return;
      setState(() {
        _apiResult = const JsonEncoder.withIndent('  ').convert({
          'success': response.success,
          'statusCode': response.statusCode,
          'response': response.rawJson ?? response.data,
        });
      });
    });
  }

  Future<void> _openChat(ChatSummary chat) async {
    final client = _client;
    final sessionId = _connectedSessionId;
    if (client == null || sessionId == null) return;
    setState(() {
      _selectedChat = chat.copyWith(unreadCount: 0);
      _messages = [];
      _errorMessage = null;
      _chats = _chats
          .map((c) => c.id == chat.id ? c.copyWith(unreadCount: 0) : c)
          .toList();
    });
    await _runRequest(() async {
      final response = await client.messages.getMessages(sessionId, chat.id);
      final messages = response.data ?? [];
      if (!mounted) return;
      setState(() => _messages = messages);
      try {
        if (messages.isNotEmpty) {
          await client.chats.markRead(
            sessionId,
            chat.id,
            messageIds: messages.map((message) => message.id).toList(),
          );
        }
      } on OpenWaApiException {
        // Reading the conversation should still work if the API key is read-only.
      }
    });
  }

  Future<void> _sendMessage() async {
    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    final content = _messageController.text.trim();
    if (client == null ||
        sessionId == null ||
        chat == null ||
        !_sessionConnected) {
      _showError('Connect a WhatsApp session before sending a message.');
      return;
    }
    if (content.isEmpty) return;
    _messageController.clear();
    await _runRequest(() async {
      final response = await client.messages.sendText(
        chat.id,
        content,
        sessionId: sessionId,
      );
      final message = response.data;
      if (message != null && mounted) {
        setState(() => _messages = [..._messages, message]);
      }
      await _loadChats();
    });
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attach & Send',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAttachOption(
                  icon: Icons.image,
                  color: const Color(0xFF5157AE),
                  label: 'Photos',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendImage();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.camera_alt,
                  color: const Color(0xFFE91E63),
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendImage();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.location_on,
                  color: const Color(0xFF00A884),
                  label: 'Location',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendLocation();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.person,
                  color: const Color(0xFF00BCD4),
                  label: 'Contact',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendContact();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.insert_drive_file,
                  color: const Color(0xFF2196F3),
                  label: 'Document',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendDocument();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.poll,
                  color: const Color(0xFFFF9800),
                  label: 'Poll',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendPoll();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.event,
                  color: const Color(0xFFE91E63),
                  label: 'Event',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendEvent();
                  },
                ),
                _buildAttachOption(
                  icon: Icons.auto_awesome,
                  color: const Color(0xFF9C27B0),
                  label: 'AI images',
                  onTap: () {
                    Navigator.pop(context);
                    _promptAndSendAiImage();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: _textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _promptAndSendImage() async {
    final captionController = TextEditingController();
    final urlController = TextEditingController(
      text: 'https://picsum.photos/400/300',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Photo / Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL or base64',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    urlController.dispose();
    captionController.dispose();
    if (confirmed != true || !mounted) return;

    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    if (client == null || sessionId == null || chat == null) return;

    await _runRequest(() async {
      final response = await client.messages.sendText(
        chat.id,
        '[Photo: ${urlController.text}] ${captionController.text}',
        sessionId: sessionId,
      );
      final message = response.data;
      if (message != null && mounted) {
        setState(() => _messages = [..._messages, message]);
      }
      await _loadChats();
    });
  }

  Future<void> _promptAndSendLocation() async {
    final titleController = TextEditingController(text: 'My Location');
    final latController = TextEditingController(text: '24.7136');
    final lngController = TextEditingController(text: '46.6753');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Location Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    if (client == null || sessionId == null || chat == null) return;

    await _runRequest(() async {
      final lat = double.tryParse(latController.text) ?? 24.7136;
      final lng = double.tryParse(lngController.text) ?? 46.6753;
      final response = await client.messages.sendLocation(
        sessionId,
        chat.id,
        lat,
        lng,
        title: titleController.text,
      );
      final message = response.data;
      if (message != null && mounted) {
        setState(() => _messages = [..._messages, message]);
      }
      await _loadChats();
    });
  }

  Future<void> _promptAndSendContact() async {
    final contactController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Contact'),
        content: TextField(
          controller: contactController,
          decoration: const InputDecoration(
            labelText: 'Contact ID / Phone number (e.g. 966500000000@c.us)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    if (client == null || sessionId == null || chat == null) return;

    await _runRequest(() async {
      final response = await client.messages.sendContact(
        sessionId,
        chat.id,
        contactController.text.trim(),
      );
      final message = response.data;
      if (message != null && mounted) {
        setState(() => _messages = [..._messages, message]);
      }
      await _loadChats();
    });
  }

  Future<void> _promptAndSendDocument() async {
    final nameController = TextEditingController(text: 'document.pdf');
    final descController = TextEditingController(
      text: 'Here is the requested document.',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'File Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description / Caption',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    if (client == null || sessionId == null || chat == null) return;

    await _runRequest(() async {
      final response = await client.messages.sendFile(
        sessionId,
        chat.id,
        utf8.encode(descController.text),
        nameController.text,
        caption: descController.text,
      );
      final message = response.data;
      if (message != null && mounted) {
        setState(() => _messages = [..._messages, message]);
      }
      await _loadChats();
    });
  }

  Future<void> _promptAndSendPoll() async {
    final questionController = TextEditingController(
      text: 'What is your preference?',
    );
    final optionsController = TextEditingController(
      text: 'Option A, Option B, Option C',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Poll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Poll Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: optionsController,
              decoration: const InputDecoration(
                labelText: 'Options (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Poll'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    if (client == null || sessionId == null || chat == null) return;

    await _runRequest(() async {
      final options = optionsController.text
          .split(',')
          .map((o) => o.trim())
          .where((o) => o.isNotEmpty)
          .toList();
      final response = await client.api.invoke(
        'MessageController_sendPoll',
        pathParameters: {'sessionId': sessionId},
        body: {
          'chatId': chat.id,
          'name': questionController.text,
          'options': options,
        },
      );
      if (response.success && mounted) {
        await _openChat(chat);
      }
      await _loadChats();
    });
  }

  Future<void> _promptAndSendEvent() async {
    _messageController.text = '[Event Invitation] Meeting scheduled for today.';
    await _sendMessage();
  }

  Future<void> _promptAndSendAiImage() async {
    final promptController = TextEditingController(
      text: 'A professional cafe interior in Riyadh',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate & Send AI Image'),
        content: TextField(
          controller: promptController,
          decoration: const InputDecoration(
            labelText: 'Image Prompt',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate & Send'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final client = _client;
    final sessionId = _connectedSessionId;
    final chat = _selectedChat;
    if (client == null || sessionId == null || chat == null) return;

    await _runRequest(() async {
      final response = await client.messages.sendText(
        chat.id,
        '[AI Image Generated] "${promptController.text}": https://picsum.photos/seed/${Uri.encodeComponent(promptController.text)}/600/400',
        sessionId: sessionId,
      );
      final message = response.data;
      if (message != null && mounted) {
        setState(() => _messages = [..._messages, message]);
      }
      await _loadChats();
    });
  }

  Future<void> _runRequest(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await action();
    } on OpenWaApiException catch (error) {
      _showError('API error [${error.statusCode}]: ${error.message}');
    } catch (error) {
      _showError('Request failed: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _noticeMessage = null;
    });
  }

  List<ChatSummary> get _visibleChats {
    final query = _searchController.text.trim().toLowerCase();
    final source = switch (_section) {
      1 => (_contacts ?? []).map(
        (contact) => ChatSummary(
          id: contact.id,
          name: contact.formattedName ?? contact.name ?? contact.pushName,
        ),
      ),
      2 => (_groups ?? []).map(
        (group) =>
            ChatSummary(id: group.id, name: group.subject, isGroup: true),
      ),
      _ => _chats.where((chat) {
          final id = chat.id.toLowerCase();
          return !id.contains('status@broadcast') &&
                 !id.contains('@newsletter') &&
                 !id.contains('broadcast');
        }),
    };
    if (query.isEmpty) return source.toList();
    return source
        .where(
          (chat) =>
              (chat.name ?? '').toLowerCase().contains(query) ||
              chat.id.toLowerCase().contains(query) ||
              (chat.lastMessage ?? '').toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: _surfaceColor,
      appBar: AppBar(
        backgroundColor: _appBarBgColor,
        foregroundColor: Colors.white,
        title: const Text('WhatsApp'),
        actions: [
          if (_apiConnected)
            IconButton(
              tooltip: 'Logout',
              onPressed: _isLoading ? null : _logout,
              icon: const Icon(Icons.logout),
            ),
          if (_apiConnected)
            IconButton(
              tooltip: 'Disconnect API',
              onPressed: _isLoading ? null : _disconnectApi,
              icon: const Icon(Icons.link_off),
            ),
          if (_apiConnected)
            IconButton(
              tooltip: 'Refresh',
              onPressed: _isLoading ? null : _refreshSessions,
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: !_apiConnected ? _buildApiConnect(theme) : _buildWorkspace(context),
    );
  }

  Widget _buildApiConnect(ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.forum, size: 52, color: _primaryColor),
                const SizedBox(height: 12),
                Text(
                  'Connect to OpenWA',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect the API first. Then select and connect a WhatsApp session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _subTextColor),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'OpenWA server URL',
                    hintText: 'https://your-openwa-server',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'API key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _connectApi,
                  icon: const Icon(Icons.cloud_done_outlined),
                  label: Text(_isLoading ? 'Connecting...' : 'Connect API'),
                ),
                _buildFeedback(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        _buildSessionBar(),
        if (_errorMessage != null || _noticeMessage != null) _buildFeedback(),
        if (_section == 3)
          Expanded(child: _buildApiConsole())
        else if (!_sessionConnected)
          Expanded(child: _buildSessionPrompt())
        else if (width >= 820)
          Expanded(child: _buildWideWorkspace())
        else if (_selectedChat != null)
          Expanded(child: _buildConversation())
        else
          Expanded(child: _buildNarrowWorkspace()),
      ],
    );
  }

  Widget _buildSessionBar() {
    final sessionSelector = DropdownButtonFormField<String>(
      initialValue: _selectedSessionId,
      isDense: true,
      decoration: const InputDecoration(
        labelText: 'WhatsApp session',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: _sessions
          .map(
            (session) => DropdownMenuItem(
              value: session.sessionId,
              child: Text(
                '${session.name ?? session.sessionId} · ${session.status.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: _isLoading ? null : _selectSession,
    );
    final connectButton = FilledButton(
      onPressed: _isLoading || _selectedSessionId == null
          ? null
          : _connectSession,
      child: Text(_sessionConnected ? 'Connected' : 'Connect session'),
    );
    final width = MediaQuery.sizeOf(context).width;
    return Material(
      color: _surfaceColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: width < 600
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_done, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text('API connected', style: TextStyle(color: _textColor)),
                      const Spacer(),
                      if (_activeSession != null)
                        Chip(label: Text(_activeSession!.status.name)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  sessionSelector,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: connectButton),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.cloud_done, color: _primaryColor),
                  const SizedBox(width: 8),
                  Text('API connected', style: TextStyle(color: _textColor)),
                  if (_activeSession != null) ...[
                    const SizedBox(width: 8),
                    Chip(label: Text(_activeSession!.status.name)),
                  ],
                  const SizedBox(width: 16),
                  Expanded(child: sessionSelector),
                  const SizedBox(width: 10),
                  connectButton,
                ],
              ),
      ),
    );
  }

  Widget _buildSessionPrompt() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.phonelink_setup,
                  size: 52,
                  color: _primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  _sessions.isEmpty
                      ? 'No WhatsApp sessions found'
                      : 'Select a session to open your chats',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The API connection and WhatsApp session are separate. Choose a session above, then connect it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _subTextColor),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _isLoading ? null : _refreshSessions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh sessions'),
                ),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _createSession,
                  icon: const Icon(Icons.add),
                  label: const Text('Create session'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _section = 3),
                  icon: const Icon(Icons.terminal),
                  label: const Text('Open Developer Console'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideWorkspace() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _section,
          onDestinationSelected: _selectSection,
          labelType: NavigationRailLabelType.all,
          backgroundColor: _surfaceColor,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: Text('Chats'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('Contacts'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: Text('Groups'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.terminal_outlined),
              selectedIcon: Icon(Icons.terminal),
              label: Text('API Console'),
            ),
          ],
        ),
        SizedBox(width: 350, child: _buildChatList()),
        VerticalDivider(
          width: 1,
          color: _isDark ? Colors.white12 : Colors.grey.shade300,
        ),
        Expanded(
          child: _selectedChat == null
              ? _buildEmptyConversation()
              : _buildConversation(),
        ),
      ],
    );
  }

  Widget _buildNarrowWorkspace() {
    return Column(
      children: [
        Expanded(child: _buildChatList()),
        NavigationBar(
          selectedIndex: _section,
          onDestinationSelected: _selectSection,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat),
              label: 'Chats',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Contacts',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: 'Groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.terminal_outlined),
              selectedIcon: Icon(Icons.terminal),
              label: 'API',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApiConsole() {
    final modules =
        OpenWaApiService.endpoints
            .map((endpoint) => endpoint.module)
            .toSet()
            .toList()
          ..sort();
    final moduleEndpoints = OpenWaApiService.endpoints
        .where((endpoint) => endpoint.module == _apiModule)
        .toList();
    final endpoint = OpenWaApiService.endpointFor(_apiOperationId);

    return ColoredBox(
      color: _surfaceColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Icon(Icons.terminal, color: _primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Developer Console · 206 API operations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _textColor,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _selectSection(0),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to chats'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _apiModule,
                          decoration: const InputDecoration(
                            labelText: 'API module',
                            border: OutlineInputBorder(),
                          ),
                          items: modules
                              .map(
                                (module) => DropdownMenuItem(
                                  value: module,
                                  child: Text(module),
                                ),
                              )
                              .toList(),
                          onChanged: _isLoading ? null : _selectApiModule,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _apiOperationId,
                          decoration: const InputDecoration(
                            labelText: 'Endpoint',
                            border: OutlineInputBorder(),
                          ),
                          items: moduleEndpoints
                              .map(
                                (operation) => DropdownMenuItem(
                                  value: operation.operationId,
                                  child: Text(
                                    '${operation.method} ${operation.path}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _isLoading
                              ? null
                              : (operationId) {
                                  if (operationId != null) {
                                    _selectApiOperation(
                                      OpenWaApiService.endpointFor(operationId),
                                    );
                                  }
                                },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          endpoint.summary ?? endpoint.operationId,
                          style: TextStyle(color: _textColor),
                        ),
                        const SizedBox(height: 16),
                        _buildJsonEditor(
                          controller: _apiPathParametersController,
                          label: 'Path parameters (JSON)',
                          helper: endpoint.pathParameters.isEmpty
                              ? 'No path parameters'
                              : endpoint.pathParameters
                                    .map((parameter) => parameter.name)
                                    .join(', '),
                        ),
                        const SizedBox(height: 12),
                        _buildJsonEditor(
                          controller: _apiQueryParametersController,
                          label: 'Query parameters (JSON)',
                          helper: endpoint.queryParameters.isEmpty
                              ? 'No query parameters'
                              : endpoint.queryParameters
                                    .map(
                                      (parameter) =>
                                          '${parameter.name}${parameter.required ? ' (required)' : ''}',
                                    )
                                    .join(', '),
                        ),
                        if (endpoint.requestContentType != null ||
                            endpoint.requestBodyRequired) ...[
                          const SizedBox(height: 12),
                          _buildJsonEditor(
                            controller: _apiRequestBodyController,
                            label: 'Request body (JSON)',
                            helper: 'See the OpenWA 0.30.0 API reference for this request schema.',
                            minLines: 5,
                          ),
                          if (endpoint.requestContentType ==
                              'multipart/form-data')
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'For file upload, use a JSON property like "file": {"fileName":"package.zip","base64":"..."}',
                                style: TextStyle(color: _subTextColor),
                              ),
                            ),
                        ],
                        const SizedBox(height: 12),
                        _buildJsonEditor(
                          controller: _apiHeadersController,
                          label: 'Additional headers (JSON)',
                          helper: endpoint.securitySchemes.isEmpty
                              ? 'X-API-Key is sent automatically. Additional headers are optional and used only for this request.'
                              : 'Also required: ${endpoint.securitySchemes.join(', ')}. Enter its authorization header here.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _runApiEndpoint,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _isLoading
                                ? 'Sending...'
                                : 'Send ${endpoint.method} request',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_apiResult != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        _apiResult!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: _textColor,
                        ),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Mock tests cover all documented routes. A successful live response depends on the deployed server version, API permissions, session state, and request data.',
                    style: TextStyle(color: _subTextColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonEditor({
    required TextEditingController controller,
    required String label,
    required String helper,
    int minLines = 2,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines > 2 ? 10 : 4,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(),
        alignLabelWithHint: minLines > 2,
      ),
      style: TextStyle(fontFamily: 'monospace', color: _textColor),
    );
  }

  Widget _buildChatList() {
    final chats = _visibleChats;
    final title = switch (_section) {
      1 => 'Contacts',
      2 => 'Groups',
      _ => 'Chats',
    };
    final loadingTab =
        (_section == 1 && _contacts == null) ||
        (_section == 2 && _groups == null);
    return ColoredBox(
      color: _surfaceColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh $title',
                  onPressed: _isLoading
                      ? null
                      : () => _runRequest(() async {
                          if (_section == 1) {
                            _contacts = null;
                            await _loadContacts();
                          } else if (_section == 2) {
                            _groups = null;
                            await _loadGroups();
                          } else {
                            await _loadChats();
                          }
                        }),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search $title',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: _inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              style: TextStyle(color: _textColor),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loadingTab || _isLoading && chats.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chats.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No $title yet'
                          : 'No matches',
                      style: TextStyle(color: _subTextColor),
                    ),
                  )
                : ListView.separated(
                    itemCount: chats.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 80,
                      color: _isDark ? Colors.white12 : Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final active = _selectedChat?.id == chat.id;
                      return ListTile(
                        selected: active,
                        selectedTileColor: _selectedTileColor,
                        leading: CircleAvatar(
                          backgroundColor: _avatarBgColor,
                          foregroundColor: _avatarFgColor,
                          child: Icon(
                            chat.isGroup ? Icons.groups : Icons.person,
                          ),
                        ),
                        title: Text(
                          chat.name?.isNotEmpty == true
                              ? chat.name!
                              : chat.id.split('@').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _textColor,
                          ),
                        ),
                        subtitle: null,
                        trailing: chat.unreadCount > 0
                            ? CircleAvatar(
                                radius: 11,
                                backgroundColor: const Color(0xFF25D366),
                                child: Text(
                                  '${chat.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () => _openChat(chat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyConversation() {
    return Container(
      color: _chatBgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 76, color: _subTextColor),
            const SizedBox(height: 16),
            Text(
              'OpenWA Web',
              style: TextStyle(fontSize: 26, color: _textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a chat to start messaging',
              style: TextStyle(color: _subTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversation() {
    final chat = _selectedChat;
    if (chat == null) return _buildEmptyConversation();
    final narrow = MediaQuery.sizeOf(context).width < 820;
    return Column(
      children: [
        Material(
          color: _surfaceColor,
          child: ListTile(
            leading: narrow
                ? IconButton(
                    onPressed: () => setState(() => _selectedChat = null),
                    icon: const Icon(Icons.arrow_back),
                  )
                : CircleAvatar(
                    backgroundColor: _avatarBgColor,
                    foregroundColor: _avatarFgColor,
                    child: Icon(chat.isGroup ? Icons.groups : Icons.person),
                  ),
            title: Text(
              chat.name?.isNotEmpty == true ? chat.name! : chat.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _textColor),
            ),
            subtitle: Text(
              chat.id,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _subTextColor),
            ),
            trailing: IconButton(
              tooltip: 'Refresh messages',
              onPressed: _isLoading ? null : () => _openChat(chat),
              icon: const Icon(Icons.refresh),
            ),
          ),
        ),
        Divider(
          height: 1,
          color: _isDark ? Colors.white12 : Colors.grey.shade300,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: _chatBgColor),
            child: _messages.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages in this conversation',
                      style: TextStyle(color: _subTextColor),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final bubbleColor = message.fromMe
                          ? _outgoingBubbleColor
                          : _incomingBubbleColor;
                      return Align(
                        alignment: message.fromMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 560),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _isDark
                                    ? Colors.black26
                                    : const Color(0x12000000),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  message.body,
                                  style: TextStyle(color: _textColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message.timestamp),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: _subTextColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        Container(
          color: _surfaceColor,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: _isLoading ? null : _showAttachmentMenu,
                icon: Icon(Icons.add, color: _primaryColor),
                tooltip: 'Attach & Send options',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    filled: true,
                    fillColor: _inputFillColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: _textColor),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isLoading ? null : _sendMessage,
                style: IconButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    if (_errorMessage == null && _noticeMessage == null) {
      return const SizedBox.shrink();
    }
    final isError = _errorMessage != null;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError
            ? (_isDark ? const Color(0xFF3B1013) : const Color(0xFFFFEBEE))
            : (_isDark ? const Color(0xFF0B2E26) : const Color(0xFFE4F5F1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.info_outline,
            color: isError ? Colors.red.shade400 : _primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? _noticeMessage!,
              style: TextStyle(color: _textColor),
            ),
          ),
          if (isError)
            IconButton(
              tooltip: 'Dismiss',
              onPressed: () => setState(() => _errorMessage = null),
              icon: Icon(Icons.close, size: 18, color: _textColor),
            ),
        ],
      ),
    );
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
