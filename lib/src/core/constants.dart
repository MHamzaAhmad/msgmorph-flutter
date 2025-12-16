/// MsgMorph SDK constants
library;

/// API endpoint paths
class ApiEndpoints {
  ApiEndpoints._();

  /// Base path for API v1
  static const String basePath = '/api/v1';

  /// Get widget configuration by public ID
  static String widgetConfig(String publicId) =>
      '$basePath/widget/config/$publicId';

  /// Submit feedback via widget
  static String submitFeedback(String publicId) =>
      '$basePath/widget/feedback/$publicId';

  /// Start a new chat session
  static const String startChat = '$basePath/chat/sessions/start';

  /// Get active session for visitor
  static const String activeSession = '$basePath/chat/sessions/active';

  /// Get messages for a session
  static String sessionMessages(String sessionId) =>
      '$basePath/chat/sessions/$sessionId/messages';

  /// Send message as visitor
  static String sendVisitorMessage(String sessionId) =>
      '$basePath/chat/sessions/$sessionId/messages/visitor';

  /// Rate a chat session
  static String rateSession(String sessionId) =>
      '$basePath/chat/sessions/$sessionId/rate';

  /// Check agent availability
  static const String checkAvailability = '$basePath/chat/availability';
}

/// Socket.io event names
class SocketEvents {
  SocketEvents._();

  // Client -> Server
  static const String joinSession = 'session:join';
  static const String leaveSession = 'session:leave';
  static const String visitorTyping = 'visitor:typing';
  static const String visitorStopTyping = 'visitor:stop-typing';

  // Server -> Client
  static const String newMessage = 'message:new';
  static const String sessionUpdated = 'session:updated';
  static const String sessionClosed = 'session:closed';
  static const String agentTyping = 'agent:typing';
  static const String agentJoined = 'agent:joined';
}

/// Local storage keys
class StorageKeys {
  StorageKeys._();

  static const String visitorId = 'msgmorph_visitor_id';
  static const String activeSessionId = 'msgmorph_active_session';
}

/// Feedback types
enum FeedbackType {
  issue('ISSUE', '🐛', 'Bug Report'),
  featureRequest('FEATURE_REQUEST', '💡', 'Idea'),
  feedback('FEEDBACK', '💬', 'Feedback'),
  other('OTHER', '✨', 'Other');

  const FeedbackType(this.value, this.emoji, this.label);

  final String value;
  final String emoji;
  final String label;

  static FeedbackType fromString(String value) {
    return FeedbackType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedbackType.other,
    );
  }
}

/// Chat session status
enum ChatSessionStatus {
  pending('PENDING'),
  active('ACTIVE'),
  transferring('TRANSFERRING'),
  closed('CLOSED'),
  expired('EXPIRED');

  const ChatSessionStatus(this.value);

  final String value;

  static ChatSessionStatus fromString(String value) {
    return ChatSessionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatSessionStatus.pending,
    );
  }
}

/// Chat message sender type
enum MessageSenderType {
  visitor('VISITOR'),
  agent('AGENT'),
  system('SYSTEM');

  const MessageSenderType(this.value);

  final String value;

  static MessageSenderType fromString(String value) {
    return MessageSenderType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MessageSenderType.system,
    );
  }
}

/// Collection requirement
enum CollectionRequirement {
  required('required'),
  optional('optional'),
  none('none');

  const CollectionRequirement(this.value);

  final String value;

  static CollectionRequirement fromString(String value) {
    return CollectionRequirement.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CollectionRequirement.none,
    );
  }
}
