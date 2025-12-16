import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/presentation/theme/msgmorph_theme.dart';

/// Offline screen shown when no agents are available
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({
    super.key,
    required this.config,
    required this.theme,
    required this.onBack,
    required this.onClose,
    this.hasOtherOptions = true,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final bool hasOtherOptions;

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
                  // Clock icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time,
                      color: theme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    "We're currently offline",
                    style: theme.headingStyle.copyWith(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Message
                  Text(
                    config.offlineMessage ??
                        'Our team is unavailable right now. Please try again later or leave us a message.',
                    style: theme.secondaryStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Leave a message button
                  if (hasOtherOptions)
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Leave a message instead',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.textColor,
                          ),
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
          if (hasOtherOptions)
            IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back,
                color: theme.secondaryTextColor,
                size: 22,
              ),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
              color: theme.secondaryTextColor,
              size: 22,
            ),
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
