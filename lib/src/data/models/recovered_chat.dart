import 'package:msgmorph_flutter/src/data/models/chat_session.dart';
import 'package:msgmorph_flutter/src/data/models/chat_message.dart';

/// Result of recovering or starting a chat session
class RecoveredChat {
  /// The chat session
  final ChatSession session;

  /// Messages in the session
  final List<ChatMessage> messages;

  /// Whether this was an existing session (true) or new session (false)
  final bool isRecovered;

  const RecoveredChat({
    required this.session,
    required this.messages,
    required this.isRecovered,
  });
}
