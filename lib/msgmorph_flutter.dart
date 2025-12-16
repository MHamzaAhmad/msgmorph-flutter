/// MsgMorph Flutter SDK
///
/// A native Flutter SDK for MsgMorph feedback widget and live chat functionality.
///
/// ## Quick Start
///
/// ```dart
/// // 1. Initialize in main.dart
/// void main() {
///   MsgMorph.init(
///     widgetId: 'your_widget_id',
///     apiBaseUrl: 'https://api.msgmorph.com',
///   );
///   runApp(const MyApp());
/// }
///
/// // 2. Use launcher variants anywhere
/// MsgMorph.floatingButton()    // FAB button
/// MsgMorph.settingsButton()    // Settings row tile
/// MsgMorph.edgeRibbon()        // Side ribbon
/// MsgMorph.inlineButton()      // Text button
///
/// // 3. Or open programmatically
/// MsgMorph.show(context);
/// MsgMorph.showFeedback(context);
/// MsgMorph.showLiveChat(context);
/// ```
library;

// Core
export 'src/core/constants.dart';
export 'src/core/exceptions.dart';

// Models
export 'src/data/models/widget_config.dart';
export 'src/data/models/widget_item.dart';
export 'src/data/models/chat_session.dart';
export 'src/data/models/chat_message.dart';
export 'src/data/models/feedback_request.dart';

// Main entry point
export 'src/msgmorph.dart';

// Widgets
export 'src/presentation/widgets/msgmorph_widget.dart';
export 'src/presentation/widgets/launchers/floating_launcher.dart';
export 'src/presentation/widgets/launchers/settings_button.dart';
export 'src/presentation/widgets/launchers/edge_ribbon.dart';
export 'src/presentation/widgets/launchers/inline_button.dart';
