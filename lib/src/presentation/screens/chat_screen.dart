import 'package:flutter/material.dart';
import 'package:msgmorph/src/data/models/widget_config.dart';
import 'package:msgmorph/src/data/models/chat_message.dart';
import 'package:msgmorph/src/state/chat_controller.dart';
import 'package:msgmorph/src/msgmorph.dart';
import 'package:msgmorph/src/presentation/theme/msgmorph_theme.dart';
import 'package:msgmorph/src/presentation/widgets/chat/message_bubble.dart';
import 'package:msgmorph/src/presentation/widgets/chat/chat_input.dart';
import 'package:msgmorph/src/presentation/widgets/chat/typing_indicator.dart';
import 'package:msgmorph/src/presentation/widgets/chat/pre_chat_form.dart';
import 'package:msgmorph/src/presentation/widgets/chat/chat_rating.dart';

/// Chat screen for live chat functionality
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.config,
    required this.theme,
    required this.onBack,
    required this.onClose,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatController _controller;
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();

  bool _showPreChatForm = true;
  bool _showRating = false;
  String _visitorName = '';
  String _visitorEmail = '';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    final visitorId = await MsgMorph.storage.getOrCreateVisitorId();
    _controller = ChatController(
      widgetId: widget.config.publicId,
      visitorId: visitorId,
    );
    _controller.addListener(_onControllerUpdate);

    // Check if pre-chat form is needed
    final preChatForm = widget.config.preChatForm;
    if (preChatForm == null || !preChatForm.enabled) {
      _showPreChatForm = false;
      _startChat();
    }

    setState(() {});
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      // Scroll to bottom when new messages arrive
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _startChat() async {
    await _controller.startChat(
      visitorName: _visitorName.isNotEmpty ? _visitorName : null,
      visitorEmail: _visitorEmail.isNotEmpty ? _visitorEmail : null,
    );
    setState(() => _showPreChatForm = false);
  }

  Future<void> _handleSendMessage() async {
    final content = _inputController.text.trim();
    if (content.isEmpty) return;

    _inputController.clear();
    await _controller.sendMessage(content);
  }

  void _handleClose() {
    if (_controller.hasSession && _controller.isSessionActive) {
      setState(() => _showRating = true);
    } else {
      widget.onClose();
    }
  }

  Future<void> _handleRateAndClose(int rating, String? feedback) async {
    if (rating > 0) {
      await _controller.rateChat(rating, feedback: feedback);
    }
    widget.onClose();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pre-chat form
    if (_showPreChatForm) {
      return PreChatFormWidget(
        config: widget.config,
        theme: widget.theme,
        onBack: widget.onBack,
        onClose: widget.onClose,
        onSubmit: (name, email) {
          _visitorName = name;
          _visitorEmail = email;
          _startChat();
        },
      );
    }

    // Rating screen
    if (_showRating) {
      return ChatRatingWidget(
        theme: widget.theme,
        onSubmit: _handleRateAndClose,
        onSkip: widget.onClose,
      );
    }

    // Loading state
    if (_controller.isConnecting) {
      return _buildLoadingState();
    }

    // Error state
    if (_controller.error != null && !_controller.hasSession) {
      return _buildErrorState();
    }

    // Chat interface
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildMessages()),
        if (_controller.isSessionActive) _buildInput(),
        if (_controller.isSessionClosed) _buildClosedBanner(),
      ],
    );
  }

  Widget _buildHeader() {
    final session = _controller.session;
    final agentName = session?.assignedAgentName ?? 'Live Chat';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: widget.theme.borderColor)),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: widget.onBack,
            icon: Icon(
              Icons.arrow_back,
              color: widget.theme.secondaryTextColor,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Agent avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          // Agent info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agentName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.theme.textColor,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _controller.isConnected
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.theme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: _handleClose,
            icon: Icon(
              Icons.close,
              color: widget.theme.secondaryTextColor,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    final session = _controller.session;
    if (session == null) return 'Connecting...';

    switch (session.status.value) {
      case 'CLOSED':
        return 'Ended';
      case 'EXPIRED':
        return 'Expired';
      case 'PENDING':
        return 'Waiting...';
      case 'ACTIVE':
        return _controller.isConnected ? 'Online' : 'Reconnecting...';
      default:
        return 'Connecting...';
    }
  }

  Widget _buildMessages() {
    final messages = _controller.messages;
    final greeting = widget.config.liveChatGreeting;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length +
          (greeting != null && messages.isEmpty ? 1 : 0) +
          (_controller.isAgentTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Greeting message
        if (greeting != null && messages.isEmpty && index == 0) {
          return MessageBubble(
            message: ChatMessage.system(sessionId: '', content: greeting),
            theme: widget.theme,
            isGreeting: true,
          );
        }

        // Adjust index for greeting
        final adjustedIndex =
            (greeting != null && messages.isEmpty) ? index - 1 : index;

        // Typing indicator
        if (adjustedIndex >= messages.length) {
          return TypingIndicatorWidget(theme: widget.theme);
        }

        return MessageBubble(
          message: messages[adjustedIndex],
          theme: widget.theme,
        );
      },
    );
  }

  Widget _buildInput() {
    return ChatInputWidget(
      controller: _inputController,
      theme: widget.theme,
      onSend: _handleSendMessage,
      onTyping: _controller.onTyping,
      isSending: _controller.isSending,
      isDisabled: !_controller.isConnected,
    );
  }

  Widget _buildClosedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: widget.theme.surfaceColor,
      child: Column(
        children: [
          Text(
            'Chat has ended',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.theme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              _controller.endSession();
              _showPreChatForm = true;
              setState(() {});
            },
            child: Text(
              'Start new chat',
              style: TextStyle(
                fontSize: 14,
                color: widget.theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Connecting...', style: widget.theme.secondaryStyle),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade400,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection failed',
              style: widget.theme.headingStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Please try again', style: widget.theme.secondaryStyle),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: widget.theme.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
