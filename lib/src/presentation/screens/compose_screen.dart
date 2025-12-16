import 'dart:io';
import 'package:flutter/material.dart';
import 'package:msgmorph_flutter/src/core/constants.dart';
import 'package:msgmorph_flutter/src/data/models/widget_config.dart';
import 'package:msgmorph_flutter/src/data/models/feedback_request.dart';
import 'package:msgmorph_flutter/src/msgmorph.dart';
import 'package:msgmorph_flutter/src/presentation/theme/msgmorph_theme.dart';

/// Compose screen for writing feedback
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    super.key,
    required this.config,
    required this.theme,
    required this.feedbackType,
    required this.onBack,
    required this.onClose,
    required this.onSubmitted,
    this.initialMessage = '',
    this.initialEmail = '',
    this.initialName = '',
    this.onMessageChanged,
    this.onEmailChanged,
    this.onNameChanged,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final FeedbackType feedbackType;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final VoidCallback onSubmitted;
  final String initialMessage;
  final String initialEmail;
  final String initialName;
  final void Function(String)? onMessageChanged;
  final void Function(String)? onEmailChanged;
  final void Function(String)? onNameChanged;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late TextEditingController _messageController;
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  final _focusNode = FocusNode();

  bool _showContactFields = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialMessage);
    _emailController = TextEditingController(text: widget.initialEmail);
    _nameController = TextEditingController(text: widget.initialName);

    // Auto focus message input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _needsContact =>
      widget.config.collectEmail != CollectionRequirement.none ||
      widget.config.collectName != CollectionRequirement.none;

  Future<void> _handleSubmit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Validate required fields
    if (widget.config.collectEmail == CollectionRequirement.required &&
        _emailController.text.trim().isEmpty) {
      setState(() {
        _showContactFields = true;
        _error = 'Email is required';
      });
      return;
    }

    if (widget.config.collectName == CollectionRequirement.required &&
        _nameController.text.trim().isEmpty) {
      setState(() {
        _showContactFields = true;
        _error = 'Name is required';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Collect device context
      final deviceContext = DeviceContext(
        screenWidth: MediaQuery.of(context).size.width.toInt(),
        screenHeight: MediaQuery.of(context).size.height.toInt(),
        platform: Platform.operatingSystem,
        language: Localizations.localeOf(context).languageCode,
        timezone: DateTime.now().timeZoneName,
      );

      await MsgMorph.submitFeedback(
        type: widget.feedbackType.value,
        content: message,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        deviceContext: deviceContext,
      );

      widget.onSubmitted();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.config.items.firstWhere(
      (i) => i.type == widget.feedbackType.value,
      orElse: () => widget.config.items.first,
    );

    return Column(
      children: [
        // Header
        _buildHeader(),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.feedbackType.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: widget.theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Message input
                TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  maxLines: 6,
                  minLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: widget.theme.inputDecoration(
                    hintText: item.placeholder,
                  ),
                  onChanged: widget.onMessageChanged,
                ),
                const SizedBox(height: 16),

                // Contact fields toggle
                if (_needsContact && !_showContactFields)
                  GestureDetector(
                    onTap: () => setState(() => _showContactFields = true),
                    child: Text.rich(
                      TextSpan(
                        text: '+ Add your contact info',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.theme.secondaryTextColor,
                        ),
                        children: [
                          if (widget.config.collectEmail ==
                                  CollectionRequirement.required ||
                              widget.config.collectName ==
                                  CollectionRequirement.required)
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Colors.red.shade400),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Contact fields expanded
                if (_needsContact && _showContactFields) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.theme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        if (widget.config.collectName !=
                            CollectionRequirement.none) ...[
                          TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: widget.theme.inputDecoration(
                              hintText: widget.config.collectName ==
                                      CollectionRequirement.required
                                  ? 'Name *'
                                  : 'Name',
                            ),
                            onChanged: widget.onNameChanged,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (widget.config.collectEmail !=
                            CollectionRequirement.none)
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: widget.theme.inputDecoration(
                              hintText: widget.config.collectEmail ==
                                      CollectionRequirement.required
                                  ? 'Email *'
                                  : 'Email',
                            ),
                            onChanged: widget.onEmailChanged,
                          ),
                      ],
                    ),
                  ),
                ],

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 13, color: Colors.red.shade500),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Send bar
        _buildSendBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: Icon(
              Icons.arrow_back,
              color: widget.theme.secondaryTextColor,
              size: 22,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              color: widget.theme.secondaryTextColor,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendBar() {
    final hasMessage = _messageController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: widget.theme.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasMessage ? '${_messageController.text.length} characters' : '',
              style: TextStyle(
                fontSize: 12,
                color: widget.theme.secondaryTextColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: hasMessage && !_isSubmitting ? _handleSubmit : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: hasMessage && !_isSubmitting
                    ? widget.theme.primaryColor
                    : widget.theme.primaryColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSubmitting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  else ...[
                    const Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.send, color: Colors.white, size: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
