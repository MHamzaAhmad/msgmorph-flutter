import 'package:msgmorph_flutter/src/core/constants.dart';

/// Chat session model
class ChatSession {
  const ChatSession({
    required this.id,
    required this.projectId,
    required this.visitorId,
    required this.roomId,
    required this.status,
    this.organizationId,
    this.visitorName,
    this.visitorEmail,
    this.assignedAgentId,
    this.assignedAgentName,
    this.subject,
    this.tags,
    this.messageCount,
    this.lastMessageAt,
    this.createdAt,
  });

  final String id;
  final String projectId;
  final String visitorId;
  final String roomId;
  final ChatSessionStatus status;
  final String? organizationId;
  final String? visitorName;
  final String? visitorEmail;
  final String? assignedAgentId;
  final String? assignedAgentName;
  final String? subject;
  final List<String>? tags;
  final int? messageCount;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  /// Check if session is active (can send messages)
  bool get isActive =>
      status == ChatSessionStatus.active || status == ChatSessionStatus.pending;

  /// Check if session is closed or expired
  bool get isClosed =>
      status == ChatSessionStatus.closed || status == ChatSessionStatus.expired;

  /// Create a copy with updated fields
  ChatSession copyWith({
    String? id,
    String? projectId,
    String? visitorId,
    String? roomId,
    ChatSessionStatus? status,
    String? organizationId,
    String? visitorName,
    String? visitorEmail,
    String? assignedAgentId,
    String? assignedAgentName,
    String? subject,
    List<String>? tags,
    int? messageCount,
    DateTime? lastMessageAt,
    DateTime? createdAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      visitorId: visitorId ?? this.visitorId,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      organizationId: organizationId ?? this.organizationId,
      visitorName: visitorName ?? this.visitorName,
      visitorEmail: visitorEmail ?? this.visitorEmail,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      assignedAgentName: assignedAgentName ?? this.assignedAgentName,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      messageCount: messageCount ?? this.messageCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      visitorId: json['visitorId'] as String,
      roomId: json['roomId'] as String,
      status: ChatSessionStatus.fromString(
        json['status'] as String? ?? 'PENDING',
      ),
      organizationId: json['organizationId'] as String?,
      visitorName: json['visitorName'] as String?,
      visitorEmail: json['visitorEmail'] as String?,
      assignedAgentId: json['assignedAgentId'] as String?,
      assignedAgentName: json['assignedAgentName'] as String?,
      subject: json['subject'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      messageCount: json['messageCount'] as int?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'visitorId': visitorId,
    'roomId': roomId,
    'status': status.value,
    if (organizationId != null) 'organizationId': organizationId,
    if (visitorName != null) 'visitorName': visitorName,
    if (visitorEmail != null) 'visitorEmail': visitorEmail,
    if (assignedAgentId != null) 'assignedAgentId': assignedAgentId,
    if (assignedAgentName != null) 'assignedAgentName': assignedAgentName,
    if (subject != null) 'subject': subject,
    if (tags != null) 'tags': tags,
    if (messageCount != null) 'messageCount': messageCount,
    if (lastMessageAt != null)
      'lastMessageAt': lastMessageAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}

/// Start chat result
class StartChatResult {
  const StartChatResult({required this.session, required this.roomId});

  final ChatSession session;
  final String roomId;

  factory StartChatResult.fromJson(Map<String, dynamic> json) {
    return StartChatResult(
      session: ChatSession.fromJson(json['session'] as Map<String, dynamic>),
      roomId: json['roomId'] as String,
    );
  }
}
