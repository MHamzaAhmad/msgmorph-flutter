/// MsgMorph SDK constants
library;

/// API endpoint paths
class ApiEndpoints {
  ApiEndpoints._();

  /// Base path for API v1
  static const String basePath = '/api/v1';

  // Widget endpoints - all use widgetId (publicId) as identifier

  /// Get widget configuration by public ID
  static String widgetConfig(String widgetId) =>
      '$basePath/widget/$widgetId/config';

  /// Submit feedback via widget
  static String submitFeedback(String widgetId) =>
      '$basePath/widget/$widgetId/feedback';

  // Chat endpoints - now under widget namespace

  /// Check agent availability
  static String checkAvailability(String widgetId) =>
      '$basePath/widget/$widgetId/chat/availability';

  /// Get active session for visitor
  static String activeSession(String widgetId) =>
      '$basePath/widget/$widgetId/chat/sessions/active';

  /// Start a new chat session
  static String startChat(String widgetId) =>
      '$basePath/widget/$widgetId/chat/sessions';

  /// Get messages for a session
  static String sessionMessages(String widgetId, String sessionId) =>
      '$basePath/widget/$widgetId/chat/sessions/$sessionId/messages';

  /// Rate a chat session
  static String rateSession(String widgetId, String sessionId) =>
      '$basePath/widget/$widgetId/chat/sessions/$sessionId/rate';

  /// Request handoff to human agent
  static String requestHandoff(String widgetId, String sessionId) =>
      '$basePath/widget/$widgetId/chat/sessions/$sessionId/handoff';
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
  issue('issue', '🐛', 'Bug Report'),
  featureRequest('feature_request', '💡', 'Idea'),
  feedback('feedback', '💬', 'Feedback'),
  other('other', '✨', 'Other');

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
