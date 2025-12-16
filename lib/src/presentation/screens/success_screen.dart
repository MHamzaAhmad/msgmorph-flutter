import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/presentation/theme/msgmorph_theme.dart';

/// Success screen after feedback submission
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    super.key,
    required this.config,
    required this.theme,
    required this.onClose,
    required this.onSendAnother,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final VoidCallback onClose;
  final VoidCallback onSendAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(),
        // Content
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: theme.primaryColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Success message
                  Text(
                    'Message sent!',
                    style: theme.headingStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.branding.thankYouMessage ??
                        "Thanks for reaching out. We'll get back to you soon.",
                    textAlign: TextAlign.center,
                    style: theme.secondaryStyle.copyWith(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Send another button
                  GestureDetector(
                    onTap: onSendAnother,
                    child: Text(
                      'Send another message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onSendAnother,
            icon: Icon(
              Icons.arrow_back,
              color: theme.secondaryTextColor,
              size: 22,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: theme.secondaryTextColor, size: 22),
          ),
        ],
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
