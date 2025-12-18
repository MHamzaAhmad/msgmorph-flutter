import 'package:flutter/material.dart';
import 'package:msgmorph/src/data/models/widget_config.dart';

/// Theme configuration derived from widget config
class MsgMorphTheme {
  const MsgMorphTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.borderColor,
  });

  final Color primaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color borderColor;

  /// Create theme from widget config
  factory MsgMorphTheme.fromConfig(WidgetConfig config) {
    final primaryColorHex = config.branding.primaryColor ?? '#000000';
    final primary = _parseColor(primaryColorHex);

    return MsgMorphTheme(
      primaryColor: primary,
      backgroundColor: Colors.white,
      surfaceColor: const Color(0xFFF5F5F5),
      textColor: const Color(0xFF1C1C1E),
      secondaryTextColor: const Color(0xFF8E8E93),
      borderColor: const Color(0xFFE5E5EA),
    );
  }

  /// Create dark theme from widget config
  factory MsgMorphTheme.darkFromConfig(WidgetConfig config) {
    final primaryColorHex = config.branding.primaryColor ?? '#FFFFFF';
    final primary = _parseColor(primaryColorHex);

    return MsgMorphTheme(
      primaryColor: primary,
      backgroundColor: const Color(0xFF1C1C1E),
      surfaceColor: const Color(0xFF2C2C2E),
      textColor: Colors.white,
      secondaryTextColor: const Color(0xFF98989D),
      borderColor: const Color(0xFF38383A),
    );
  }

  /// Parse hex color string
  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Get primary color with opacity
  Color primaryWithOpacity(double opacity) =>
      primaryColor.withValues(alpha: opacity);

  /// Get text style for headings
  TextStyle get headingStyle => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: -0.5,
      );

  /// Get text style for body text
  TextStyle get bodyStyle =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textColor);

  /// Get text style for secondary text
  TextStyle get secondaryStyle => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
      );

  /// Get text style for buttons
  TextStyle get buttonStyle => const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  /// Get pill button decoration
  BoxDecoration get pillDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      );

  /// Get primary button decoration
  BoxDecoration get primaryButtonDecoration => BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
      );

  /// Get card decoration
  BoxDecoration get cardDecoration => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      );

  /// Get input decoration
  InputDecoration inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: secondaryTextColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
