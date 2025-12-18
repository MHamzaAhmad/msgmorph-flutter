import 'dart:async';
import 'package:msgmorph/src/data/services/socket_service.dart';
import 'package:msgmorph/src/data/models/chat_message.dart';
import 'package:msgmorph/src/data/models/chat_session.dart';

/// Real-time chat client for live updates
///
/// Provides streams for receiving real-time messages and events,
/// as well as methods for emitting typing status.
///
/// Example:
/// ```dart
/// final chatClient = await MsgMorph.createChatClient(sessionId);
/// await chatClient.connect();
///
/// chatClient.onMessage.listen((message) {
///   print('New message: ${message.content}');
/// });
///
/// chatClient.onAgentTyping.listen((isTyping) {
///   print('Agent is typing: $isTyping');
/// });
///
/// // Send typing indicator
/// chatClient.sendTypingStart();
///
/// // Cleanup when done
/// chatClient.disconnect();
/// chatClient.dispose();
/// ```
class ChatClient {
  ChatClient({
    required this.serverUrl,
    required this.sessionId,
    required this.visitorId,
  });

  final String serverUrl;
  final String sessionId;
  final String visitorId;

  SocketService? _socket;

  /// Whether the client is connected
  bool get isConnected => _socket?.isConnected ?? false;

  /// Whether the client is connecting
  bool get isConnecting => _socket?.isConnecting ?? false;

  /// Connect to the chat server
  ///
  /// Call this after creating the client to start receiving events.
  Future<void> connect() async {
    _socket = SocketService(
      serverUrl: serverUrl,
      visitorId: visitorId,
      sessionId: sessionId,
    );
    await _socket!.connect();
  }

  /// Disconnect from the chat server
  void disconnect() {
    _socket?.disconnect();
  }

  // ==================== Event Streams ====================

  /// Stream of new messages
  ///
  /// Emits when a new message is received in the chat session.
  Stream<ChatMessage> get onMessage =>
      _socket?.onMessage ?? const Stream.empty();

  /// Stream of session updates
  ///
  /// Emits when the session status changes (e.g., assigned to agent).
  Stream<ChatSession> get onSessionUpdate =>
      _socket?.onSessionUpdate ?? const Stream.empty();

  /// Stream of session closed events
  ///
  /// Emits the close reason when the session is closed.
  Stream<String> get onSessionClosed =>
      _socket?.onSessionClosed ?? const Stream.empty();

  /// Stream of agent typing status
  ///
  /// Emits true when agent starts typing, false after timeout.
  Stream<bool> get onAgentTyping =>
      _socket?.onAgentTyping ?? const Stream.empty();

  /// Stream of connection status changes
  Stream<bool> get onConnectionChange =>
      _socket?.onConnectionChange ?? const Stream.empty();

  /// Stream of error messages
  Stream<String> get onError => _socket?.onError ?? const Stream.empty();

  // ==================== Actions ====================

  /// Emit typing started event
  ///
  /// Call this when the user starts typing.
  void sendTypingStart() {
    _socket?.emitTyping();
  }

  /// Emit typing stopped event
  ///
  /// Call this when the user stops typing.
  void sendTypingStop() {
    _socket?.emitStopTyping();
  }

  /// Dispose resources
  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
