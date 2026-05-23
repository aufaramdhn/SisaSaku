import 'package:flutter/material.dart';

/// Displays 4–6 dot indicators showing PIN entry progress.
/// Supports error state with shake animation.
class PinInputField extends StatefulWidget {
  /// The current number of digits entered.
  final int currentLength;

  /// The maximum PIN length (4–6).
  final int maxLength;

  /// Whether the field is in error state (triggers shake animation).
  final bool hasError;

  const PinInputField({
    super.key,
    required this.currentLength,
    this.maxLength = 6,
    this.hasError = false,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(PinInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = _shakeAnimation.value *
            8 *
            ((_shakeController.value * 4).toInt().isEven ? 1 : -1);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.maxLength, (index) {
          final isFilled = index < widget.currentLength;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.hasError
                  ? colorScheme.error
                  : isFilled
                      ? colorScheme.primary
                      : Colors.transparent,
              border: Border.all(
                color: widget.hasError
                    ? colorScheme.error
                    : isFilled
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }
}
