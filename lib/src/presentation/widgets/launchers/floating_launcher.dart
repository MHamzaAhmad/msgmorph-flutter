import 'package:flutter/material.dart';
import 'package:msgmorph/src/msgmorph.dart';

/// Floating action button launcher
///
/// Classic FAB that opens the MsgMorph widget when tapped.
class FloatingLauncher extends StatelessWidget {
  const FloatingLauncher({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.heroTag,
  });

  /// Background color of the FAB
  final Color? backgroundColor;

  /// Icon color
  final Color? iconColor;

  /// Size of the FAB (default: 56)
  final double? size;

  /// Hero tag for the FAB
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final config = MsgMorph.config;
    final primaryColor = config != null
        ? _parseColor(config.branding.primaryColor ?? '#000000')
        : Colors.black;

    final bgColor = backgroundColor ?? primaryColor;
    final fgColor = iconColor ?? Colors.white;
    final fabSize = size ?? 56.0;

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        heroTag: heroTag ?? 'msgmorph_fab',
        backgroundColor: bgColor,
        onPressed: () => MsgMorph.show(context),
        elevation: 4,
        child: Icon(
          Icons.chat_bubble_rounded,
          color: fgColor,
          size: fabSize * 0.43,
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
