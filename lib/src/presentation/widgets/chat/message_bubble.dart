import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/data/models/chat_message.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/presentation/theme/msgmorph_theme.dart';

/// Chat message bubble widget
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.theme,
    this.isGreeting = false,
  });

  final ChatMessage message;
  final MsgMorphTheme theme;
  final bool isGreeting;

  @override
  Widget build(BuildContext context) {
    final isVisitor = message.senderType == MessageSenderType.visitor;
    final isSystem = message.senderType == MessageSenderType.system;

    // System message
    if (isSystem && !isGreeting) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(fontSize: 12, color: theme.secondaryTextColor),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isVisitor
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Agent avatar (for non-visitor messages)
          if (!isVisitor) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isGreeting ? Icons.chat_bubble_outline : Icons.headset_mic,
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isVisitor ? theme.primaryColor : theme.surfaceColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isVisitor ? 16 : 4),
                  bottomRight: Radius.circular(isVisitor ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isVisitor ? Colors.white : theme.textColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
