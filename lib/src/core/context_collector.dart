// Device Context Collector for Flutter
//
// Collects comprehensive device context for debugging.
// Used when submitting feedback or starting live chat.
//
// Note: No OS-level permissions are required for this data.

import 'dart:io';
import 'dart:ui';

/// Device context for debugging
class DeviceContext {
  final String platform;
  final String deviceType;
  final String os;
  final String? osVersion;
  final int screenWidth;
  final int screenHeight;
  final double? pixelRatio;
  final String? orientation;
  final String? appVersion;
  final String? appBuildNumber;
  final String timezone;
  final String language;
  final String? locale;
  final String? connectionType;

  DeviceContext({
    required this.platform,
    required this.deviceType,
    required this.os,
    this.osVersion,
    required this.screenWidth,
    required this.screenHeight,
    this.pixelRatio,
    this.orientation,
    this.appVersion,
    this.appBuildNumber,
    required this.timezone,
    required this.language,
    this.locale,
    this.connectionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'deviceType': deviceType,
      'os': os,
      if (osVersion != null) 'osVersion': osVersion,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      if (pixelRatio != null) 'pixelRatio': pixelRatio,
      if (orientation != null) 'orientation': orientation,
      if (appVersion != null) 'appVersion': appVersion,
      if (appBuildNumber != null) 'appBuildNumber': appBuildNumber,
      'timezone': timezone,
      'language': language,
      if (locale != null) 'locale': locale,
      if (connectionType != null) 'connectionType': connectionType,
    };
  }
}

/// Context collector utility
class ContextCollector {
  /// Detect device type (phone or tablet)
  static String _detectDeviceType() {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final shortSide = size.shortestSide;

    // Tablets typically have shortest side > 600dp
    if (shortSide > 600) {
      return 'tablet';
    }
    return 'mobile';
  }

  /// Get screen orientation
  static String _getOrientation() {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    return size.height >= size.width ? 'portrait' : 'landscape';
  }

  /// Collect device context
  static DeviceContext collect() {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final locale = PlatformDispatcher.instance.locale;

    return DeviceContext(
      // Device Info
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceType: _detectDeviceType(),
      os: Platform.isIOS ? 'iOS' : 'Android',
      osVersion: Platform.operatingSystemVersion,

      // Screen
      screenWidth: size.width.round(),
      screenHeight: size.height.round(),
      pixelRatio: view.devicePixelRatio,
      orientation: _getOrientation(),

      // Locale
      timezone: DateTime.now().timeZoneName,
      language: locale.languageCode,
      locale: locale.toLanguageTag(),

      // Connection type not collected (would require permissions)
      connectionType: 'unknown',
    );
  }
}
