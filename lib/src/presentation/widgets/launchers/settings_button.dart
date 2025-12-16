import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/msgmorph.dart';

/// Settings row button launcher
///
/// ListTile-style widget for use in settings or menu screens.
class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    this.title = 'Send Feedback',
    this.subtitle,
    this.leading,
    this.trailing,
  });

  /// Title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Leading widget (defaults to feedback icon)
  final Widget? leading;

  /// Trailing widget (defaults to chevron icon)
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final config = MsgMorph.config;
    final primaryColor = config != null
        ? _parseColor(config.branding.primaryColor ?? '#000000')
        : Theme.of(context).primaryColor;

    return ListTile(
      leading: leading ??
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.feedback_outlined, color: primaryColor, size: 22),
          ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            )
          : null,
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: () => MsgMorph.show(context),
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
