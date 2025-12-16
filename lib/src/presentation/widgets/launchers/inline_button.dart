import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/msgmorph.dart';

/// Inline text button launcher
///
/// Simple text button for inline placement anywhere in the UI.
class InlineButton extends StatelessWidget {
  const InlineButton({super.key, this.text = 'Send Feedback', this.style});

  /// Button text
  final String text;

  /// Custom text style
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final config = MsgMorph.config;
    final primaryColor = config != null
        ? _parseColor(config.branding.primaryColor ?? '#000000')
        : Theme.of(context).primaryColor;

    return TextButton(
      onPressed: () => MsgMorph.show(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style:
            style ??
            TextStyle(
              color: primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
