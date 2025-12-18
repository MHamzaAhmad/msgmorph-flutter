import 'package:flutter/material.dart';
import 'package:msgmorph/src/presentation/theme/msgmorph_theme.dart';

/// Post-chat rating widget
class ChatRatingWidget extends StatefulWidget {
  const ChatRatingWidget({
    super.key,
    required this.theme,
    required this.onSubmit,
    required this.onSkip,
  });

  final MsgMorphTheme theme;
  final void Function(int rating, String? feedback) onSubmit;
  final VoidCallback onSkip;

  @override
  State<ChatRatingWidget> createState() => _ChatRatingWidgetState();
}

class _ChatRatingWidgetState extends State<ChatRatingWidget> {
  int _rating = 0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How was your experience?',
              style: widget.theme.headingStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us improve',
              style: widget.theme.secondaryStyle,
            ),
            const SizedBox(height: 24),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = starNumber),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      _rating >= starNumber ? Icons.star : Icons.star_border,
                      color: _rating >= starNumber
                          ? Colors.amber
                          : widget.theme.secondaryTextColor,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Feedback input
            if (_rating > 0) ...[
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: widget.theme.inputDecoration(
                  hintText: 'Additional feedback (optional)',
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Submit button
            GestureDetector(
              onTap: () => widget.onSubmit(
                _rating,
                _feedbackController.text.trim().isNotEmpty
                    ? _feedbackController.text.trim()
                    : null,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _rating > 0
                      ? widget.theme.primaryColor
                      : widget.theme.primaryColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skip button
            GestureDetector(
              onTap: widget.onSkip,
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.theme.secondaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
