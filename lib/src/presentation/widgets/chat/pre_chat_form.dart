import 'package:flutter/material.dart';
import 'package:msgmorph/src/data/models/widget_config.dart';
import 'package:msgmorph/src/presentation/theme/msgmorph_theme.dart';

/// Pre-chat form for collecting visitor information
class PreChatFormWidget extends StatefulWidget {
  const PreChatFormWidget({
    super.key,
    required this.config,
    required this.theme,
    required this.onBack,
    required this.onClose,
    required this.onSubmit,
  });

  final WidgetConfig config;
  final MsgMorphTheme theme;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final void Function(String name, String email) onSubmit;

  @override
  State<PreChatFormWidget> createState() => _PreChatFormWidgetState();
}

class _PreChatFormWidgetState extends State<PreChatFormWidget> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final preChatForm = widget.config.preChatForm;
    if (preChatForm == null) {
      widget.onSubmit('', '');
      return;
    }

    // Validate required fields
    for (final field in preChatForm.fields) {
      if (!field.required) continue;

      if (field.type == 'email' && _emailController.text.trim().isEmpty) {
        setState(() => _error = 'Email is required');
        return;
      }
      if (field.type == 'text' &&
          field.id == 'name' &&
          _nameController.text.trim().isEmpty) {
        setState(() => _error = 'Name is required');
        return;
      }
    }

    // Validate email format
    if (_emailController.text.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        setState(() => _error = 'Please enter a valid email');
        return;
      }
    }

    widget.onSubmit(_nameController.text.trim(), _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final preChatForm = widget.config.preChatForm;
    final fields = preChatForm?.fields ?? [];

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
                Text('Start a conversation', style: widget.theme.headingStyle),
                const SizedBox(height: 8),
                Text(
                  'Fill out the form below to chat with us',
                  style: widget.theme.secondaryStyle,
                ),
                const SizedBox(height: 24),

                // Dynamic fields
                for (final field in fields) ...[
                  _buildField(field),
                  const SizedBox(height: 16),
                ],

                // Error
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 13, color: Colors.red.shade500),
                  ),
                  const SizedBox(height: 16),
                ],

                // Submit button
                GestureDetector(
                  onTap: _handleSubmit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: widget.theme.primaryButtonDecoration,
                    child: const Center(
                      child: Text(
                        'Start Chat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildField(PreChatFormField field) {
    final isRequired = field.required;

    switch (field.type) {
      case 'email':
        return TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: widget.theme.inputDecoration(
            hintText: '${field.label}${isRequired ? ' *' : ''}',
          ),
        );
      case 'text':
      default:
        if (field.id == 'name' || field.label.toLowerCase().contains('name')) {
          return TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: widget.theme.inputDecoration(
              hintText: '${field.label}${isRequired ? ' *' : ''}',
            ),
          );
        }
        return TextField(
          decoration: widget.theme.inputDecoration(
            hintText: '${field.label}${isRequired ? ' *' : ''}',
          ),
        );
    }
  }
}
