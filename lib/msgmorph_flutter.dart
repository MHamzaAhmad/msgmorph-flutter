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
/// // 2. Use built-in launchers
/// MsgMorph.floatingButton()    // FAB button
/// MsgMorph.settingsButton()    // Settings row tile
/// MsgMorph.edgeRibbon()        // Side ribbon
/// MsgMorph.inlineButton()      // Text button
///
/// // 3. Open modals programmatically
/// MsgMorph.show(context);
/// MsgMorph.showFeedback(context);
/// MsgMorph.showLiveChat(context);
///
/// // 4. Or use headless APIs for custom UI
/// await MsgMorph.submitFeedback(type: 'issue', content: '...');
/// final session = await MsgMorph.startChat();
/// final messages = await MsgMorph.getMessages(session.id);
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
export 'src/data/models/recovered_chat.dart';

// Main entry point
export 'src/msgmorph.dart';

// Services (Advanced usage)
export 'src/data/services/api_client.dart';
export 'src/data/services/socket_service.dart';
export 'src/data/services/chat_client.dart';

// Widgets
export 'src/presentation/widgets/msgmorph_widget.dart';
export 'src/presentation/widgets/launchers/floating_launcher.dart';
export 'src/presentation/widgets/launchers/settings_button.dart';
export 'src/presentation/widgets/launchers/edge_ribbon.dart';
export 'src/presentation/widgets/launchers/inline_button.dart';
