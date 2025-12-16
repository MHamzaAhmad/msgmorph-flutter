import 'package:msgmorph_flutter/src/core/constants.dart';

/// Chat message attachment
class MessageAttachment {
  const MessageAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  final String id;
  final String name;
  final String url;
  final String type;
  final int size;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'type': type,
    'size': size,
  };
}

/// Chat message model
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderType,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.type = 'TEXT',
    this.attachments,
    this.isRead = false,
  });

  final String id;
  final String sessionId;
  final MessageSenderType senderType;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String? senderName;
  final String type;
  final List<MessageAttachment>? attachments;
  final bool isRead;

  /// Check if message is from visitor
  bool get isFromVisitor => senderType == MessageSenderType.visitor;

  /// Check if message is from agent
  bool get isFromAgent => senderType == MessageSenderType.agent;

  /// Check if message is a system message
  bool get isSystem => senderType == MessageSenderType.system;

  /// Create an optimistic message (before server confirmation)
  factory ChatMessage.optimistic({
    required String sessionId,
    required String visitorId,
    required String content,
    String? visitorName,
  }) {
    return ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      senderType: MessageSenderType.visitor,
      senderId: visitorId,
      senderName: visitorName,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// Create a system message
  factory ChatMessage.system({
    required String sessionId,
    required String content,
  }) {
    return ChatMessage(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      senderType: MessageSenderType.system,
      senderId: 'system',
      senderName: 'System',
      content: content,
      createdAt: DateTime.now(),
      type: 'SYSTEM',
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      senderType: MessageSenderType.fromString(
        json['senderType'] as String? ?? 'SYSTEM',
      ),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'TEXT',
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'senderType': senderType.value,
    'senderId': senderId,
    if (senderName != null) 'senderName': senderName,
    'content': content,
    'type': type,
    if (attachments != null)
      'attachments': attachments!.map((e) => e.toJson()).toList(),
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };
}
