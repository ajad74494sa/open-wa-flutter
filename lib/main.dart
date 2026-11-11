import 'package:flutter/material.dart';
import 'package:open_wa/open_wa.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenWaApp());
}

class OpenWaApp extends StatelessWidget {
  const OpenWaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenWA Client SDK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF128C7E), // WhatsApp teal branding
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF128C7E),
          brightness: Brightness.dark,
        ),
      ),
      home: const OpenWaHomeScreen(),
    );
  }
}

class OpenWaHomeScreen extends StatefulWidget {
  const OpenWaHomeScreen({super.key});

  @override
  State<OpenWaHomeScreen> createState() => _OpenWaHomeScreenState();
}

class _OpenWaHomeScreenState extends State<OpenWaHomeScreen> {
  final _baseUrlController = TextEditingController(text: 'https://api.yourdomain.com');
  final _apiKeyController = TextEditingController(text: '');
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();

  OpenWaClient? _client;
  bool _isConnected = false;
  bool _isLoading = false;
  String _statusMessage = 'Not Connected';
  final List<ChatMessage> _messageHistory = [];
  SessionInfo? _currentSession;

  @override
  void dispose() {
    _client?.close();
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _initializeClient() {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();

    if (baseUrl.isEmpty || apiKey.isEmpty) {
      _showSnackBar('Please provide both Base URL and API Key.');
      return;
    }

    try {
      _client?.close();
      _client = OpenWaClient.create(
        baseUrl: baseUrl,
        apiKey: apiKey,
        requireHttps: true,
      );

      setState(() {
        _isConnected = true;
        _statusMessage = 'Client initialized successfully';
      });

      _checkSessionStatus();
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Initialization error: $e';
      });
    }
  }

  Future<void> _checkSessionStatus() async {
    if (_client == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await _client!.sessions.getSessionInfo('default');
      setState(() {
        _currentSession = response.data;
        _statusMessage = 'Session state: ${response.data?.status.name ?? "Unknown"}';
      });
    } on OpenWaApiException catch (e) {
      setState(() => _statusMessage = 'API Error [${e.statusCode}]: ${e.message}');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_client == null) {
      _showSnackBar('Please initialize client first.');
      return;
    }

    final recipient = _recipientController.text.trim();
    final content = _messageController.text.trim();

    if (recipient.isEmpty || content.isEmpty) {
      _showSnackBar('Recipient and Message Content are required.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _client!.messages.sendText(recipient, content);
      if (response.success && response.data != null) {
        setState(() {
          _messageHistory.insert(0, response.data!);
          _messageController.clear();
        });
        _showSnackBar('Message sent successfully!');
      } else {
        _showSnackBar(response.message ?? 'Failed to send message.');
      }
    } catch (e) {
      _showSnackBar('Error sending message: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenWA 100% Secure Client SDK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isConnected ? _checkSessionStatus : null,
            tooltip: 'Refresh Session',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Config Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.lock_outline : Icons.lock_open,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Secure Server Connection',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'OpenWA Base URL',
                        hintText: 'https://w.kheyalcafe.com',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'API Key (Bearer Auth)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _initializeClient,
                      icon: const Icon(Icons.key),
                      label: const Text('Connect Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Status Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.primary.withAlpha(100)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                            ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (_currentSession != null) ...[
                    const Divider(height: 16),
                    Text(
                      'Session ID: ${_currentSession!.sessionId} | Status: ${_currentSession!.status.name} | Phone: ${_currentSession!.phoneNumber ?? "N/A"}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Messaging Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send WhatsApp Message',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _recipientController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Phone Number or JID',
                        hintText: '1234567890@c.us',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Message Body',
                        hintText: 'Hello from OpenWA Dart SDK!',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isConnected && !_isLoading ? _sendMessage : null,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Message'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message History List
            if (_messageHistory.isNotEmpty) ...[
              Text(
                'Recent Messages',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _messageHistory.length,
                itemBuilder: (context, index) {
                  final msg = _messageHistory[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.chat)),
                      title: Text(msg.to),
                      subtitle: Text(msg.body),
                      trailing: Text(
                        DateTime.fromMillisecondsSinceEpoch(msg.timestamp)
                            .toLocal()
                            .toString()
                            .split('.')
                            .first,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
