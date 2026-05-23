import 'package:flutter/material.dart';

/// A 4x3 numeric keypad widget for PIN entry.
/// Displays digits 0–9, a delete button, and an empty cell.
class NumericKeypad extends StatelessWidget {
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;

  const NumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow([1, 2, 3]),
        const SizedBox(height: 12),
        _buildRow([4, 5, 6]),
        const SizedBox(height: 12),
        _buildRow([7, 8, 9]),
        const SizedBox(height: 12),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) => _buildDigitButton(digit)).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Empty cell
        const SizedBox(width: 72, height: 72),
        _buildDigitButton(0),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildDigitButton(int digit) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDigitPressed(digit),
          borderRadius: BorderRadius.circular(36),
          child: Center(
            child: Text(
              '$digit',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDeletePressed,
          borderRadius: BorderRadius.circular(36),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
