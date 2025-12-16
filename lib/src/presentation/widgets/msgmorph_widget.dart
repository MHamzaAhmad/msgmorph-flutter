import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/presentation/screens/widget_home_screen.dart';
import 'package:msgmorph_flutter/src/presentation/screens/compose_screen.dart';
import 'package:msgmorph_flutter/src/presentation/screens/success_screen.dart';
import 'package:msgmorph_flutter/src/presentation/screens/chat_screen.dart';
import 'package:msgmorph_flutter/src/presentation/screens/offline_screen.dart';
import 'package:msgmorph_flutter/src/presentation/theme/msgmorph_theme.dart';

/// Widget screen states
enum WidgetScreen {
  home,
  compose,
  success,
  liveChat,
  preChatForm,
  chatRating,
  offline
}

/// Main MsgMorph widget container
///
/// Displays the full widget UI with navigation between screens.
class MsgMorphWidget extends StatefulWidget {
  const MsgMorphWidget({
    super.key,
    required this.config,
    this.initialScreen = WidgetScreen.home,
    this.initialFeedbackType,
    this.onClose,
  });

  final WidgetConfig config;
  final WidgetScreen initialScreen;
  final FeedbackType? initialFeedbackType;
  final VoidCallback? onClose;

  @override
  State<MsgMorphWidget> createState() => _MsgMorphWidgetState();
}

class _MsgMorphWidgetState extends State<MsgMorphWidget> {
  late WidgetScreen _currentScreen;
  FeedbackType? _selectedFeedbackType;
  String _feedbackMessage = '';
  String _email = '';
  String _name = '';

  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialScreen;
    _selectedFeedbackType = widget.initialFeedbackType;

    // If only live chat is enabled, go directly to chat
    if (widget.config.feedbackItems.isEmpty && widget.config.hasLiveChat) {
      _currentScreen = WidgetScreen.liveChat;
    }

    // If feedback type is pre-selected, go to compose
    if (_selectedFeedbackType != null && _currentScreen == WidgetScreen.home) {
      _currentScreen = WidgetScreen.compose;
    }
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleBack() {
    setState(() {
      switch (_currentScreen) {
        case WidgetScreen.compose:
          _currentScreen = WidgetScreen.home;
          _selectedFeedbackType = null;
          _feedbackMessage = '';
          break;
        case WidgetScreen.success:
          _currentScreen = WidgetScreen.home;
          _resetForm();
          break;
        case WidgetScreen.liveChat:
        case WidgetScreen.preChatForm:
        case WidgetScreen.chatRating:
        case WidgetScreen.offline:
          _currentScreen = WidgetScreen.home;
          break;
        case WidgetScreen.home:
          _handleClose();
          break;
      }
    });
  }

  void _handleSelectFeedbackType(FeedbackType type) {
    setState(() {
      _selectedFeedbackType = type;
      _currentScreen = WidgetScreen.compose;
    });
  }

  void _handleStartLiveChat() {
    setState(() {
      _currentScreen = WidgetScreen.liveChat;
    });
  }

  void _handleShowOffline() {
    setState(() {
      _currentScreen = WidgetScreen.offline;
    });
  }

  void _handleFeedbackSubmitted() {
    setState(() {
      _currentScreen = WidgetScreen.success;
    });
  }

  void _resetForm() {
    _selectedFeedbackType = null;
    _feedbackMessage = '';
    _email = '';
    _name = '';
  }

  void _handleSendAnother() {
    setState(() {
      _resetForm();
      _currentScreen = WidgetScreen.home;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MsgMorphTheme.fromConfig(widget.config);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(child: _buildScreen(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(MsgMorphTheme theme) {
    switch (_currentScreen) {
      case WidgetScreen.home:
        return WidgetHomeScreen(
          config: widget.config,
          theme: theme,
          onClose: _handleClose,
          onSelectFeedbackType: _handleSelectFeedbackType,
          onStartLiveChat: _handleStartLiveChat,
          onShowOffline: _handleShowOffline,
        );
      case WidgetScreen.compose:
        return ComposeScreen(
          config: widget.config,
          theme: theme,
          feedbackType: _selectedFeedbackType!,
          initialMessage: _feedbackMessage,
          initialEmail: _email,
          initialName: _name,
          onBack: _handleBack,
          onClose: _handleClose,
          onSubmitted: _handleFeedbackSubmitted,
          onMessageChanged: (msg) => _feedbackMessage = msg,
          onEmailChanged: (email) => _email = email,
          onNameChanged: (name) => _name = name,
        );
      case WidgetScreen.success:
        return SuccessScreen(
          config: widget.config,
          theme: theme,
          onClose: _handleClose,
          onSendAnother: _handleSendAnother,
        );
      case WidgetScreen.liveChat:
      case WidgetScreen.preChatForm:
      case WidgetScreen.chatRating:
        return ChatScreen(
          config: widget.config,
          theme: theme,
          onBack: _handleBack,
          onClose: _handleClose,
        );
      case WidgetScreen.offline:
        return OfflineScreen(
          config: widget.config,
          theme: theme,
          onBack: _handleBack,
          onClose: _handleClose,
          hasOtherOptions: widget.config.feedbackItems.isNotEmpty,
        );
    }
  }
}
