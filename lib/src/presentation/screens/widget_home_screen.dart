import 'package:flutter/material.dart';
import 'package:msgmorph/src/core/constants.dart';
import 'package:msgmorph/src/data/models/widget_config.dart';
import 'package:msgmorph/src/presentation/theme/msgmorph_theme.dart';

/// Home screen of the widget
///
/// Shows greeting, feedback type buttons, and optional live chat button.
/// Checks agent availability before showing live chat option.
class WidgetHomeScreen extends StatefulWidget {
  const WidgetHomeScreen({
    super.key,
    required this.config,
    required this.theme,
    required this.onClose,
    required this.onSelectFeedbackType,
    required this.onStartLiveChat,
    required this.onShowOffline,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final VoidCallback onClose;
  final void Function(FeedbackType) onSelectFeedbackType;
  final VoidCallback onStartLiveChat;
  final VoidCallback onShowOffline;

  @override
  State<WidgetHomeScreen> createState() => _WidgetHomeScreenState();
}

class _WidgetHomeScreenState extends State<WidgetHomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _handleLiveChatTap() {
    widget.onStartLiveChat();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackItems = widget.config.feedbackItems;
    final hasLiveChat = widget.config.hasLiveChat;

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
                  widget.config.branding.title ?? 'Hey there 👋',
                  style: widget.theme.headingStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.config.branding.subtitle ??
                      'How can we help you today?',
                  style: widget.theme.secondaryStyle,
                ),
                const SizedBox(height: 24),

                // Feedback types
                if (feedbackItems.isNotEmpty) ...[
                  Text(
                    'Send us a message',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.secondaryTextColor,
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
                        theme: widget.theme,
                        onTap: () => widget.onSelectFeedbackType(
                          FeedbackType.fromString(item.type),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Live chat
                if (hasLiveChat) ...[
                  const SizedBox(height: 24),
                  _LiveChatButton(
                    theme: widget.theme,
                    onTap: _handleLiveChatTap,
                  ),
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
          if (widget.config.branding.logoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.config.branding.logoUrl!,
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
            onPressed: widget.onClose,
            icon: Icon(Icons.close,
                color: widget.theme.secondaryTextColor, size: 22),
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
        color: widget.theme.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: widget.theme.borderColor)),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'Powered by ',
            style:
                TextStyle(fontSize: 12, color: widget.theme.secondaryTextColor),
            children: [
              TextSpan(
                text: 'MsgMorph',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.theme.secondaryTextColor,
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
  const _LiveChatButton({
    required this.theme,
    required this.onTap,
  });

  final MsgMorphTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const subtitle = 'Instant AI support • Humans available on request';

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
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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
