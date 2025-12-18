import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show showModalBottomSheet, Colors;
import 'package:msgmorph_flutter/src/core/exceptions.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/data/models/feedback_request.dart';
import 'package:msgmorph_flutter/src/data/models/chat_session.dart';
import 'package:msgmorph_flutter/src/data/models/chat_message.dart';
import 'package:msgmorph_flutter/src/data/models/recovered_chat.dart';
import 'package:msgmorph_flutter/src/data/services/api_client.dart';
import 'package:msgmorph_flutter/src/data/services/storage_service.dart';
import 'package:msgmorph_flutter/src/data/services/chat_client.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/msgmorph_widget.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/floating_launcher.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/settings_button.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/edge_ribbon.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/inline_button.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';

/// Main entry point for MsgMorph SDK
///
/// Initialize once in your app's main function:
/// ```dart
/// void main() {
///   MsgMorph.init(
///     widgetId: 'your_widget_id',
///     apiBaseUrl: 'https://api.msgmorph.com',
///   );
///   runApp(const MyApp());
/// }
/// ```
class MsgMorph {
  MsgMorph._();

  static MsgMorph? _instance;
  static ApiClient? _apiClient;
  static StorageService? _storage;

  // Configuration
  static String? _widgetId;
  static String? _apiBaseUrl;
  static WidgetConfig? _config;
  static bool _isInitialized = false;

  /// Get the singleton instance
  static MsgMorph get instance {
    if (_instance == null) {
      throw const NotInitializedException();
    }
    return _instance!;
  }

  /// Check if SDK is initialized
  static bool get isInitialized => _isInitialized;

  /// Get current widget configuration
  static WidgetConfig? get config => _config;

  /// Get widget ID
  static String get widgetId {
    if (_widgetId == null) {
      throw const NotInitializedException();
    }
    return _widgetId!;
  }

  /// Get API base URL
  static String get apiBaseUrl {
    if (_apiBaseUrl == null) {
      throw const NotInitializedException();
    }
    return _apiBaseUrl!;
  }

  /// Get API client
  static ApiClient get apiClient {
    if (_apiClient == null) {
      throw const NotInitializedException();
    }
    return _apiClient!;
  }

  /// Get storage service
  static StorageService get storage {
    if (_storage == null) {
      throw const NotInitializedException();
    }
    return _storage!;
  }

  // ==================== Initialization ====================

  /// Initialize MsgMorph SDK
  ///
  /// Must be called before using any other MsgMorph functionality.
  ///
  /// [widgetId] - Your MsgMorph widget public ID
  /// [apiBaseUrl] - API server URL (defaults to https://api.msgmorph.com)
  static Future<void> init({
    required String widgetId,
    String apiBaseUrl = 'https://api.msgmorph.com',
  }) async {
    _widgetId = widgetId;
    _apiBaseUrl = apiBaseUrl;
    _apiClient = ApiClient(baseUrl: apiBaseUrl);
    _storage = StorageService.instance;
    _instance = MsgMorph._();

    // Initialize storage
    await _storage!.init();

    _isInitialized = true;
  }

  /// Load widget configuration from server
  static Future<WidgetConfig> loadConfig() async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    _config = await _apiClient!.getWidgetConfig(_widgetId!);
    return _config!;
  }

  // ==================== Launcher Widgets ====================

  /// Floating action button launcher
  ///
  /// Use in Scaffold's floatingActionButton:
  /// ```dart
  /// Scaffold(
  ///   body: YourContent(),
  ///   floatingActionButton: MsgMorph.floatingButton(),
  /// )
  /// ```
  static Widget floatingButton({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
  }) {
    return FloatingLauncher(
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
    );
  }

  /// Settings row button launcher
  ///
  /// Use in settings screens as a ListTile:
  /// ```dart
  /// ListView(
  ///   children: [
  ///     MsgMorph.settingsButton(
  ///       title: 'Send Feedback',
  ///       subtitle: 'Report bugs or request features',
  ///     ),
  ///   ],
  /// )
  /// ```
  static Widget settingsButton({
    String title = 'Send Feedback',
    String? subtitle,
    Widget? leading,
    Widget? trailing,
  }) {
    return SettingsButton(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
    );
  }

  /// Edge ribbon launcher
  ///
  /// Vertical tab on right edge of screen:
  /// ```dart
  /// Stack(
  ///   children: [
  ///     YourMainContent(),
  ///     MsgMorph.edgeRibbon(),
  ///   ],
  /// )
  /// ```
  static Widget edgeRibbon({
    String text = 'Feedback',
    Color? backgroundColor,
    Color? textColor,
    Alignment alignment = Alignment.centerRight,
  }) {
    return EdgeRibbon(
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
      alignment: alignment,
    );
  }

  /// Inline text button launcher
  ///
  /// Simple text button for inline use:
  /// ```dart
  /// Row(
  ///   children: [
  ///     Text('Need help?'),
  ///     MsgMorph.inlineButton(text: 'Contact Us'),
  ///   ],
  /// )
  /// ```
  static Widget inlineButton({
    String text = 'Send Feedback',
    TextStyle? style,
  }) {
    return InlineButton(
      text: text,
      style: style,
    );
  }

  // ==================== Programmatic Control ====================

  /// Show the widget modal
  ///
  /// Opens the full widget with home screen.
  static Future<void> show(BuildContext context) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    // Load config if not already loaded
    if (_config == null) {
      await loadConfig();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MsgMorphWidget(config: _config!),
    );
  }

  /// Show feedback form directly
  ///
  /// Opens widget with feedback compose screen.
  /// Optionally pre-select a feedback type.
  static Future<void> showFeedback(
    BuildContext context, {
    FeedbackType? type,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    if (_config == null) {
      await loadConfig();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MsgMorphWidget(
        config: _config!,
        initialScreen: type != null ? WidgetScreen.compose : WidgetScreen.home,
        initialFeedbackType: type,
      ),
    );
  }

  /// Show live chat directly
  ///
  /// Opens widget with live chat screen.
  static Future<void> showLiveChat(BuildContext context) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    if (_config == null) {
      await loadConfig();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MsgMorphWidget(
        config: _config!,
        initialScreen: WidgetScreen.liveChat,
      ),
    );
  }

  // ==================== Feedback Submission ====================

  /// Submit feedback programmatically
  ///
  /// Use for custom feedback forms.
  static Future<FeedbackResponse> submitFeedback({
    required String type,
    required String content,
    String? email,
    String? name,
    Map<String, dynamic>? customFields,
    DeviceContext? deviceContext,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    return _apiClient!.submitFeedback(
      _widgetId!,
      FeedbackRequest(
        type: type,
        content: content,
        email: email,
        name: name,
        customFields: customFields,
        deviceContext: deviceContext,
      ),
    );
  }

  // ==================== Chat API (Headless) ====================

  /// Check if agents are available for live chat
  ///
  /// Returns true if at least one agent is online and available.
  static Future<bool> checkAvailability() async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }
    return _apiClient!.checkAvailability(_widgetId!);
  }

  /// Get active chat session for current visitor
  ///
  /// Returns null if no active session exists.
  static Future<ChatSession?> getActiveSession() async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }
    final visitorId = await _storage!.getVisitorId();
    if (visitorId == null) return null;

    final result = await _apiClient!.recoverSession(
      widgetId: _widgetId!,
      visitorId: visitorId,
    );
    return result?.session;
  }

  /// Start a new chat session
  ///
  /// [initialMessage] - Optional first message to send
  /// [visitorName] - Optional display name for the visitor
  /// [visitorEmail] - Optional email address
  /// [subject] - Optional subject/topic
  /// [metadata] - Optional custom metadata
  /// [deviceContext] - Optional device context
  static Future<StartChatResult> startChat({
    String? initialMessage,
    String? visitorName,
    String? visitorEmail,
    String? subject,
    Map<String, dynamic>? metadata,
    DeviceContext? deviceContext,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    final visitorId = await _storage!.getOrCreateVisitorId();

    return _apiClient!.startChat(
      widgetId: _widgetId!,
      visitorId: visitorId,
      visitorName: visitorName,
      visitorEmail: visitorEmail,
      initialMessage: initialMessage,
      subject: subject,
      metadata: metadata,
      deviceContext: deviceContext,
    );
  }

  /// Recover existing chat session with messages, or start a new one
  ///
  /// This is the recommended method for headless chat implementations.
  /// It will:
  /// 1. Try to recover an existing active session
  /// 2. Load all messages from the session
  /// 3. If no session exists, start a new one
  /// 4. Return both the session and messages
  ///
  /// Example:
  /// ```dart
  /// final result = await MsgMorph.recoverOrStartChat();
  /// print('Session: ${result.session.id}');
  /// print('Messages: ${result.messages.length}');
  /// ```
  static Future<RecoveredChat> recoverOrStartChat({
    String? visitorName,
    String? visitorEmail,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    final visitorId = await _storage!.getOrCreateVisitorId();

    // Try to recover existing session
    final recoveryResult = await _apiClient!.recoverSession(
      widgetId: _widgetId!,
      visitorId: visitorId,
    );

    if (recoveryResult != null && recoveryResult.session.status != 'CLOSED') {
      // Load existing messages
      final messages = await _apiClient!.getMessages(
        _widgetId!,
        recoveryResult.session.id,
      );
      return RecoveredChat(
        session: recoveryResult.session,
        messages: messages,
        isRecovered: true,
      );
    }

    // Start new session
    final startResult = await _apiClient!.startChat(
      widgetId: _widgetId!,
      visitorId: visitorId,
      visitorName: visitorName,
      visitorEmail: visitorEmail,
    );

    // Load messages (in case there's an initial greeting)
    final messages = await _apiClient!.getMessages(
      _widgetId!,
      startResult.session.id,
    );

    return RecoveredChat(
      session: startResult.session,
      messages: messages,
      isRecovered: false,
    );
  }

  /// Get messages for a chat session
  static Future<List<ChatMessage>> getMessages(String sessionId) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }
    return _apiClient!.getMessages(_widgetId!, sessionId);
  }

  /// Send a message in a chat session
  ///
  /// [sessionId] - The chat session ID
  /// [content] - Message content
  /// [visitorName] - Optional display name
  static Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
    String? visitorName,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    final visitorId = await _storage!.getOrCreateVisitorId();

    return _apiClient!.sendMessage(
      widgetId: _widgetId!,
      sessionId: sessionId,
      content: content,
      visitorId: visitorId,
      visitorName: visitorName,
    );
  }

  /// Rate a chat session
  ///
  /// [sessionId] - The chat session ID
  /// [rating] - Rating from 1-5
  /// [feedback] - Optional feedback text
  static Future<void> rateChat({
    required String sessionId,
    required int rating,
    String? feedback,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    await _apiClient!.rateChat(
      widgetId: _widgetId!,
      sessionId: sessionId,
      rating: rating,
      feedback: feedback,
    );
  }

  /// Request handoff to a human agent
  static Future<void> requestHandoff(String sessionId) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    final visitorId = await _storage!.getOrCreateVisitorId();

    await _apiClient!.requestHandoff(
      widgetId: _widgetId!,
      sessionId: sessionId,
      visitorId: visitorId,
    );
  }

  /// Create a ChatClient for real-time chat updates
  ///
  /// Use this to receive real-time messages and typing events.
  ///
  /// Example:
  /// ```dart
  /// final chatClient = await MsgMorph.createChatClient(sessionId);
  /// await chatClient.connect();
  ///
  /// chatClient.onMessage.listen((message) {
  ///   print('New message: ${message.content}');
  /// });
  /// ```
  static Future<ChatClient> createChatClient(String sessionId) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    final visitorId = await _storage!.getOrCreateVisitorId();

    return ChatClient(
      serverUrl: _apiBaseUrl!,
      sessionId: sessionId,
      visitorId: visitorId,
    );
  }

  /// Dispose resources
  static void dispose() {
    _apiClient?.dispose();
    _instance = null;
    _apiClient = null;
    _storage = null;
    _config = null;
    _widgetId = null;
    _apiBaseUrl = null;
    _isInitialized = false;
  }
}
