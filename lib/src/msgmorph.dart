import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show showModalBottomSheet, Colors;
import 'package:msgmorph_flutter/src/core/exceptions.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/data/models/feedback_request.dart';
import 'package:msgmorph_flutter/src/data/services/api_client.dart';
import 'package:msgmorph_flutter/src/data/services/storage_service.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/msgmorph_widget.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/floating_launcher.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/settings_button.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/edge_ribbon.dart';
import 'package:msgmorph_flutter/src/presentation/widgets/launchers/inline_button.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';

/// Main entry point for MsgMorph SDK
///
/// Initialize once in your app's main function:
/// ```dart
/// void main() {
///   MsgMorph.init(
///     widgetId: 'your_widget_id',
///     apiBaseUrl: 'https://api.msgmorph.com',
///   );
///   runApp(const MyApp());
/// }
/// ```
class MsgMorph {
  MsgMorph._();

  static MsgMorph? _instance;
  static ApiClient? _apiClient;
  static StorageService? _storage;

  // Configuration
  static String? _widgetId;
  static String? _apiBaseUrl;
  static WidgetConfig? _config;
  static bool _isInitialized = false;

  /// Get the singleton instance
  static MsgMorph get instance {
    if (_instance == null) {
      throw const NotInitializedException();
    }
    return _instance!;
  }

  /// Check if SDK is initialized
  static bool get isInitialized => _isInitialized;

  /// Get current widget configuration
  static WidgetConfig? get config => _config;

  /// Get widget ID
  static String get widgetId {
    if (_widgetId == null) {
      throw const NotInitializedException();
    }
    return _widgetId!;
  }

  /// Get API base URL
  static String get apiBaseUrl {
    if (_apiBaseUrl == null) {
      throw const NotInitializedException();
    }
    return _apiBaseUrl!;
  }

  /// Get API client
  static ApiClient get apiClient {
    if (_apiClient == null) {
      throw const NotInitializedException();
    }
    return _apiClient!;
  }

  /// Get storage service
  static StorageService get storage {
    if (_storage == null) {
      throw const NotInitializedException();
    }
    return _storage!;
  }

  // ==================== Initialization ====================

  /// Initialize MsgMorph SDK
  ///
  /// Must be called before using any other MsgMorph functionality.
  ///
  /// [widgetId] - Your MsgMorph widget public ID
  /// [apiBaseUrl] - API server URL (defaults to https://api.msgmorph.com)
  static Future<void> init({
    required String widgetId,
    String apiBaseUrl = 'https://api.msgmorph.com',
  }) async {
    _widgetId = widgetId;
    _apiBaseUrl = apiBaseUrl;
    _apiClient = ApiClient(baseUrl: apiBaseUrl);
    _storage = StorageService.instance;
    _instance = MsgMorph._();

    // Initialize storage
    await _storage!.init();

    _isInitialized = true;
  }

  /// Load widget configuration from server
  static Future<WidgetConfig> loadConfig() async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    _config = await _apiClient!.getWidgetConfig(_widgetId!);
    return _config!;
  }

  // ==================== Launcher Widgets ====================

  /// Floating action button launcher
  ///
  /// Use in Scaffold's floatingActionButton:
  /// ```dart
  /// Scaffold(
  ///   body: YourContent(),
  ///   floatingActionButton: MsgMorph.floatingButton(),
  /// )
  /// ```
  static Widget floatingButton({
    Color? backgroundColor,
    Color? iconColor,
    double? size,
  }) {
    return FloatingLauncher(
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
    );
  }

  /// Settings row button launcher
  ///
  /// Use in settings screens as a ListTile:
  /// ```dart
  /// ListView(
  ///   children: [
  ///     MsgMorph.settingsButton(
  ///       title: 'Send Feedback',
  ///       subtitle: 'Report bugs or request features',
  ///     ),
  ///   ],
  /// )
  /// ```
  static Widget settingsButton({
    String title = 'Send Feedback',
    String? subtitle,
    Widget? leading,
    Widget? trailing,
  }) {
    return SettingsButton(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
    );
  }

  /// Edge ribbon launcher
  ///
  /// Vertical tab on right edge of screen:
  /// ```dart
  /// Stack(
  ///   children: [
  ///     YourMainContent(),
  ///     MsgMorph.edgeRibbon(),
  ///   ],
  /// )
  /// ```
  static Widget edgeRibbon({
    String text = 'Feedback',
    Color? backgroundColor,
    Color? textColor,
    Alignment alignment = Alignment.centerRight,
  }) {
    return EdgeRibbon(
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
      alignment: alignment,
    );
  }

  /// Inline text button launcher
  ///
  /// Simple text button for inline use:
  /// ```dart
  /// Row(
  ///   children: [
  ///     Text('Need help?'),
  ///     MsgMorph.inlineButton(text: 'Contact Us'),
  ///   ],
  /// )
  /// ```
  static Widget inlineButton({
    String text = 'Send Feedback',
    TextStyle? style,
  }) {
    return InlineButton(
      text: text,
      style: style,
    );
  }

  // ==================== Programmatic Control ====================

  /// Show the widget modal
  ///
  /// Opens the full widget with home screen.
  static Future<void> show(BuildContext context) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    // Load config if not already loaded
    if (_config == null) {
      await loadConfig();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MsgMorphWidget(config: _config!),
    );
  }

  /// Show feedback form directly
  ///
  /// Opens widget with feedback compose screen.
  /// Optionally pre-select a feedback type.
  static Future<void> showFeedback(
    BuildContext context, {
    FeedbackType? type,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    if (_config == null) {
      await loadConfig();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MsgMorphWidget(
        config: _config!,
        initialScreen: type != null ? WidgetScreen.compose : WidgetScreen.home,
        initialFeedbackType: type,
      ),
    );
  }

  /// Show live chat directly
  ///
  /// Opens widget with live chat screen.
  static Future<void> showLiveChat(BuildContext context) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    if (_config == null) {
      await loadConfig();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MsgMorphWidget(
        config: _config!,
        initialScreen: WidgetScreen.liveChat,
      ),
    );
  }

  // ==================== Feedback Submission ====================

  /// Submit feedback programmatically
  ///
  /// Use for custom feedback forms.
  static Future<FeedbackResponse> submitFeedback({
    required String type,
    required String content,
    String? email,
    String? name,
    Map<String, dynamic>? customFields,
    DeviceContext? deviceContext,
  }) async {
    if (!_isInitialized) {
      throw const NotInitializedException();
    }

    return _apiClient!.submitFeedback(
      _widgetId!,
      FeedbackRequest(
        type: type,
        content: content,
        email: email,
        name: name,
        customFields: customFields,
        deviceContext: deviceContext,
      ),
    );
  }

  /// Dispose resources
  static void dispose() {
    _apiClient?.dispose();
    _instance = null;
    _apiClient = null;
    _storage = null;
    _config = null;
    _widgetId = null;
    _apiBaseUrl = null;
    _isInitialized = false;
  }
}
