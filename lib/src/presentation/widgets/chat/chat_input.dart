import 'package:flutter/material.dart';
import 'package:msgmorph/src/presentation/theme/msgmorph_theme.dart';

/// Chat message input widget
class ChatInputWidget extends StatelessWidget {
  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.theme,
    required this.onSend,
    required this.onTyping,
    this.isSending = false,
    this.isDisabled = false,
  });

  final TextEditingController controller;
  final MsgMorphTheme theme;
  final VoidCallback onSend;
  final VoidCallback onTyping;
  final bool isSending;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text input
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isDisabled,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: theme.secondaryTextColor),
                  filled: true,
                  fillColor: theme.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => onTyping(),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            GestureDetector(
              onTap: isDisabled || isSending ? null : onSend,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? theme.primaryColor.withValues(alpha: 0.4)
                      : theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
