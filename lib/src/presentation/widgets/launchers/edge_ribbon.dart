import 'package:flutter/material.dart';
import 'package:msgmorph/src/msgmorph.dart';

/// Edge ribbon launcher
///
/// Vertical tab on the edge of screen that opens the widget when tapped.
class EdgeRibbon extends StatelessWidget {
  const EdgeRibbon({
    super.key,
    this.text = 'Feedback',
    this.backgroundColor,
    this.textColor,
    this.alignment = Alignment.centerRight,
  });

  /// Text to display on the ribbon
  final String text;

  /// Background color of the ribbon
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Alignment on screen (centerRight or centerLeft)
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final config = MsgMorph.config;
    final primaryColor = config != null
        ? _parseColor(config.branding.primaryColor ?? '#000000')
        : Colors.black;

    final bgColor = backgroundColor ?? primaryColor;
    final fgColor = textColor ?? Colors.white;
    final isRight = alignment == Alignment.centerRight;

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: () => MsgMorph.show(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: isRight
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: Offset(isRight ? -2 : 2, 0),
                ),
              ],
            ),
            child: RotatedBox(
              quarterTurns: isRight ? 3 : 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.feedback_outlined, color: fgColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
