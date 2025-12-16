import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/presentation/theme/msgmorph_theme.dart';

/// Home screen of the widget
///
/// Shows greeting, feedback type buttons, and optional live chat button.
class WidgetHomeScreen extends StatelessWidget {
  const WidgetHomeScreen({
    super.key,
    required this.config,
    required this.theme,
    required this.onClose,
    required this.onSelectFeedbackType,
    required this.onStartLiveChat,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final VoidCallback onClose;
  final void Function(FeedbackType) onSelectFeedbackType;
  final VoidCallback onStartLiveChat;

  @override
  Widget build(BuildContext context) {
    final feedbackItems = config.feedbackItems;
    final hasLiveChat = config.hasLiveChat;

    return Column(
      children: [
        // Header
        _buildHeader(),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  config.branding.title ?? 'Hey there 👋',
                  style: theme.headingStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  config.branding.subtitle ?? 'How can we help you today?',
                  style: theme.secondaryStyle,
                ),
                const SizedBox(height: 24),

                // Feedback types
                if (feedbackItems.isNotEmpty) ...[
                  Text(
                    'Send us a message',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.secondaryTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: feedbackItems.map((item) {
                      return _FeedbackTypeButton(
                        item: item,
                        theme: theme,
                        onTap: () => onSelectFeedbackType(
                          FeedbackType.fromString(item.type),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Live chat
                if (hasLiveChat) ...[
                  const SizedBox(height: 24),
                  _LiveChatButton(theme: theme, onTap: onStartLiveChat),
                ],
              ],
            ),
          ),
        ),
        // Footer
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo or icon
          if (config.branding.logoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                config.branding.logoUrl!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultLogo(),
              ),
            )
          else
            _buildDefaultLogo(),
          // Close button
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: theme.secondaryTextColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'Powered by ',
            style: TextStyle(fontSize: 12, color: theme.secondaryTextColor),
            children: [
              TextSpan(
                text: 'MsgMorph',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feedback type pill button
class _FeedbackTypeButton extends StatelessWidget {
  const _FeedbackTypeButton({
    required this.item,
    required this.theme,
    required this.onTap,
  });

  final dynamic item;
  final MsgMorphTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: theme.pillDecoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live chat CTA button
class _LiveChatButton extends StatelessWidget {
  const _LiveChatButton({required this.theme, required this.onTap});

  final MsgMorphTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.textColor, theme.textColor.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chat with us',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'We typically reply in minutes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
