import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/core/exceptions.dart';
import 'package:msgmorph_flutter/src/data/models/chat_message.dart';
import 'package:msgmorph_flutter/src/data/models/chat_session.dart';

/// Socket.io service for real-time chat functionality
class SocketService {
  SocketService({
    required this.serverUrl,
    required this.visitorId,
    required this.sessionId,
  });

  final String serverUrl;
  final String visitorId;
  final String sessionId;

  io.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;

  // Stream controllers for events
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _sessionUpdateController = StreamController<ChatSession>.broadcast();
  final _sessionClosedController = StreamController<String>.broadcast();
  final _agentTypingController = StreamController<bool>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  /// Stream of new messages
  Stream<ChatMessage> get onMessage => _messageController.stream;

  /// Stream of session updates
  Stream<ChatSession> get onSessionUpdate => _sessionUpdateController.stream;

  /// Stream of session closed events
  Stream<String> get onSessionClosed => _sessionClosedController.stream;

  /// Stream of agent typing status
  Stream<bool> get onAgentTyping => _agentTypingController.stream;

  /// Stream of connection status
  Stream<bool> get onConnectionChange => _connectionController.stream;

  /// Stream of errors
  Stream<String> get onError => _errorController.stream;

  /// Whether socket is connected
  bool get isConnected => _isConnected;

  /// Whether socket is connecting
  bool get isConnecting => _isConnecting;

  /// Connect to socket server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    _isConnecting = true;
    _connectionController.add(false);

    try {
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setQuery({
              'clientId': visitorId,
              'clientType': 'visitor',
              'sessionId': sessionId,
            })
            .enableAutoConnect()
            .enableReconnection()
            .build(),
      );

      _setupListeners();
    } catch (e) {
      _isConnecting = false;
      throw SocketConnectionException('Failed to connect: $e');
    }
  }

  /// Setup socket event listeners
  void _setupListeners() {
    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionController.add(true);

      // Join the session room
      _socket!.emit(SocketEvents.joinSession, {'sessionId': sessionId});
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      _isConnecting = false;
      _errorController.add('Connection error: $error');
    });

    _socket!.onError((error) {
      _errorController.add('Socket error: $error');
    });

    // Listen for new messages
    _socket!.on(SocketEvents.newMessage, (data) {
      try {
        final message = ChatMessage.fromJson(data as Map<String, dynamic>);
        _messageController.add(message);
      } catch (e) {
        _errorController.add('Failed to parse message: $e');
      }
    });

    // Listen for session updates
    _socket!.on(SocketEvents.sessionUpdated, (data) {
      try {
        final sessionData = data as Map<String, dynamic>;
        if (sessionData['id'] == sessionId) {
          // Create partial session update
          _sessionUpdateController.add(ChatSession.fromJson(sessionData));
        }
      } catch (e) {
        _errorController.add('Failed to parse session update: $e');
      }
    });

    // Listen for session closed
    _socket!.on(SocketEvents.sessionClosed, (data) {
      final sessionData = data as Map<String, dynamic>;
      if (sessionData['sessionId'] == sessionId) {
        final reason = sessionData['reason'] as String? ?? 'Chat session ended';
        _sessionClosedController.add(reason);
      }
    });

    // Listen for agent typing
    _socket!.on(SocketEvents.agentTyping, (data) {
      final typingData = data as Map<String, dynamic>;
      if (typingData['sessionId'] == sessionId) {
        _agentTypingController.add(true);

        // Auto-clear typing after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (!_agentTypingController.isClosed) {
            _agentTypingController.add(false);
          }
        });
      }
    });
  }

  /// Emit visitor typing event
  void emitTyping() {
    _socket?.emit(SocketEvents.visitorTyping, {'sessionId': sessionId});
  }

  /// Emit visitor stop typing event
  void emitStopTyping() {
    _socket?.emit(SocketEvents.visitorStopTyping, {'sessionId': sessionId});
  }

  /// Disconnect from socket server
  void disconnect() {
    if (_socket != null) {
      _socket!.emit(SocketEvents.leaveSession, {'sessionId': sessionId});
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _isConnecting = false;
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _messageController.close();
    _sessionUpdateController.close();
    _sessionClosedController.close();
    _agentTypingController.close();
    _connectionController.close();
    _errorController.close();
  }
}
