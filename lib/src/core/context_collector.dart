// Device Context Collector for Flutter
//
// Collects comprehensive device context for debugging.
// Used when submitting feedback or starting live chat.
//
// Uses device_info_plus for accurate device information.

import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';

/// Device context for debugging
class DeviceContext {
  final String platform;
  final String deviceType;
  final String os;
  final String? osVersion;
  final String? deviceModel;
  final String? deviceBrand;
  final String? deviceManufacturer;
  final bool? isPhysicalDevice;
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
    this.deviceModel,
    this.deviceBrand,
    this.deviceManufacturer,
    this.isPhysicalDevice,
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
      if (deviceModel != null) 'deviceModel': deviceModel,
      if (deviceBrand != null) 'deviceBrand': deviceBrand,
      if (deviceManufacturer != null) 'deviceManufacturer': deviceManufacturer,
      if (isPhysicalDevice != null) 'isPhysicalDevice': isPhysicalDevice,
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
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

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

  /// Collect device context (async for device_info_plus)
  static Future<DeviceContext> collectAsync() async {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final locale = PlatformDispatcher.instance.locale;

    String? deviceModel;
    String? deviceBrand;
    String? deviceManufacturer;
    String? osVersion;
    bool? isPhysicalDevice;

    try {
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceModel = iosInfo.model;
        deviceBrand = 'Apple';
        deviceManufacturer = 'Apple';
        osVersion = iosInfo.systemVersion;
        isPhysicalDevice = iosInfo.isPhysicalDevice;
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceModel = androidInfo.model;
        deviceBrand = androidInfo.brand;
        deviceManufacturer = androidInfo.manufacturer;
        osVersion = androidInfo.version.release;
        isPhysicalDevice = androidInfo.isPhysicalDevice;
      }
    } catch (e) {
      // Fallback to basic info if device_info_plus fails
      osVersion = Platform.operatingSystemVersion;
    }

    return DeviceContext(
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceType: _detectDeviceType(),
      os: Platform.isIOS ? 'iOS' : 'Android',
      osVersion: osVersion ?? Platform.operatingSystemVersion,
      deviceModel: deviceModel,
      deviceBrand: deviceBrand,
      deviceManufacturer: deviceManufacturer,
      isPhysicalDevice: isPhysicalDevice,
      screenWidth: size.width.round(),
      screenHeight: size.height.round(),
      pixelRatio: view.devicePixelRatio,
      orientation: _getOrientation(),
      timezone: DateTime.now().timeZoneName,
      language: locale.languageCode,
      locale: locale.toLanguageTag(),
      connectionType: 'unknown',
    );
  }

  /// Collect device context (sync fallback - less detailed)
  static DeviceContext collect() {
    final view = PlatformDispatcher.instance.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final locale = PlatformDispatcher.instance.locale;

    return DeviceContext(
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceType: _detectDeviceType(),
      os: Platform.isIOS ? 'iOS' : 'Android',
      osVersion: Platform.operatingSystemVersion,
      screenWidth: size.width.round(),
      screenHeight: size.height.round(),
      pixelRatio: view.devicePixelRatio,
      orientation: _getOrientation(),
      timezone: DateTime.now().timeZoneName,
      language: locale.languageCode,
      locale: locale.toLanguageTag(),
      connectionType: 'unknown',
    );
  }
}
