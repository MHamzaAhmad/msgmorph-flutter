import 'dart:async';
import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/data/models/chat_session.dart';
import 'package:msgmorph_flutter/src/data/models/chat_message.dart';
import 'package:msgmorph_flutter/src/data/services/socket_service.dart';
import 'package:msgmorph_flutter/src/msgmorph.dart';

/// Controller for chat state management
class ChatController extends ChangeNotifier {
  ChatController({required this.projectId, required this.visitorId});

  final String projectId;
  final String visitorId;

  // State
  ChatSession? _session;
  List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isAgentTyping = false;
  bool _isSending = false;
  String? _error;

  // Services
  SocketService? _socketService;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _sessionUpdateSubscription;
  StreamSubscription? _sessionClosedSubscription;
  StreamSubscription? _agentTypingSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _errorSubscription;

  // Typing debounce
  Timer? _typingTimer;

  // Getters
  ChatSession? get session => _session;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  bool get isAgentTyping => _isAgentTyping;
  bool get isSending => _isSending;
  String? get error => _error;
  bool get hasSession => _session != null;
  bool get isSessionActive => _session?.isActive ?? false;
  bool get isSessionClosed => _session?.isClosed ?? false;

  /// Start or recover a chat session
  Future<void> startChat({
    String? visitorName,
    String? visitorEmail,
    String? initialMessage,
    String? subject,
  }) async {
    _error = null;
    _isConnecting = true;
    notifyListeners();

    try {
      final api = MsgMorph.apiClient;

      // Try to recover existing session first
      final recovered = await api.recoverSession(
        visitorId: visitorId,
        projectId: projectId,
      );

      if (recovered != null) {
        _session = recovered.session;
        _messages = await api.getMessages(_session!.id);
        await _connectSocket();
      } else {
        // Start new session
        final result = await api.startChat(
          projectId: projectId,
          visitorId: visitorId,
          visitorName: visitorName,
          visitorEmail: visitorEmail,
          initialMessage: initialMessage,
          subject: subject,
        );
        _session = result.session;
        if (initialMessage != null) {
          _messages = await api.getMessages(_session!.id);
        }
        await _connectSocket();
      }

      // Save session ID
      await MsgMorph.storage.setActiveSessionId(_session!.id);

      _isConnecting = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Connect to socket for real-time updates
  Future<void> _connectSocket() async {
    if (_session == null) return;

    _socketService = SocketService(
      serverUrl: MsgMorph.apiBaseUrl,
      visitorId: visitorId,
      sessionId: _session!.id,
    );

    // Subscribe to streams
    _messageSubscription = _socketService!.onMessage.listen((message) {
      // Ignore messages from self (already handled via optimistic update + API response)
      if (message.senderId == visitorId) return;

      // Avoid duplicates (by ID)
      if (!_messages.any((m) => m.id == message.id)) {
        _messages.add(message);
        notifyListeners();
      }
    });

    _sessionUpdateSubscription = _socketService!.onSessionUpdate.listen((
      update,
    ) {
      if (_session != null) {
        _session = _session!.copyWith(
          status: update.status,
          assignedAgentId: update.assignedAgentId,
          assignedAgentName: update.assignedAgentName,
        );
        notifyListeners();
      }
    });

    _sessionClosedSubscription = _socketService!.onSessionClosed.listen((
      reason,
    ) {
      _session = _session?.copyWith(status: ChatSessionStatus.closed);
      _messages.add(
        ChatMessage.system(sessionId: _session!.id, content: reason),
      );
      notifyListeners();
    });

    _agentTypingSubscription = _socketService!.onAgentTyping.listen((isTyping) {
      _isAgentTyping = isTyping;
      notifyListeners();
    });

    _connectionSubscription = _socketService!.onConnectionChange.listen((
      connected,
    ) {
      _isConnected = connected;
      notifyListeners();
    });

    _errorSubscription = _socketService!.onError.listen((error) {
      _error = error;
      notifyListeners();
    });

    await _socketService!.connect();
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (_session == null || content.trim().isEmpty) return;

    _isSending = true;
    _error = null;
    notifyListeners();

    // Add optimistic message
    final optimisticMessage = ChatMessage.optimistic(
      sessionId: _session!.id,
      visitorId: visitorId,
      content: content,
    );
    _messages.add(optimisticMessage);
    notifyListeners();

    try {
      final api = MsgMorph.apiClient;
      final sentMessage = await api.sendMessage(
        sessionId: _session!.id,
        content: content,
        visitorId: visitorId,
        visitorName: _session!.visitorName,
      );

      // Replace optimistic message with real one
      final index = _messages.indexWhere((m) => m.id == optimisticMessage.id);
      if (index != -1) {
        _messages[index] = sentMessage;
      }

      _isSending = false;
      notifyListeners();
    } catch (e) {
      // Remove optimistic message on error
      _messages.removeWhere((m) => m.id == optimisticMessage.id);
      _error = e.toString();
      _isSending = false;
      notifyListeners();
    }
  }

  /// Handle typing indicator
  void onTyping() {
    _socketService?.emitTyping();

    // Debounce stop typing
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _socketService?.emitStopTyping();
    });
  }

  /// Rate the chat session
  Future<void> rateChat(int rating, {String? feedback}) async {
    if (_session == null) return;

    try {
      await MsgMorph.apiClient.rateChat(
        sessionId: _session!.id,
        rating: rating,
        feedback: feedback,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// End the session and clear state
  void endSession() {
    _socketService?.disconnect();
    _session = null;
    _messages = [];
    MsgMorph.storage.setActiveSessionId(null);
    notifyListeners();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _sessionUpdateSubscription?.cancel();
    _sessionClosedSubscription?.cancel();
    _agentTypingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    _socketService?.dispose();
    super.dispose();
  }
}
