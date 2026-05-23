import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/features/security/presentation/providers/security_provider.dart';
import 'package:sisasaku/features/security/presentation/widgets/numeric_keypad.dart';
import 'package:sisasaku/features/security/presentation/widgets/pin_input_field.dart';

/// Verifies current PIN before change or disable operations.
/// Returns true via Navigator result on success.
class PinVerifyPage extends ConsumerStatefulWidget {
  const PinVerifyPage({super.key});

  @override
  ConsumerState<PinVerifyPage> createState() => _PinVerifyPageState();
}

class _PinVerifyPageState extends ConsumerState<PinVerifyPage> {
  String _enteredPin = '';
  bool _hasError = false;
  static const int _pinLength = 6;

  void _onDigitPressed(int digit) {
    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _hasError = false;
      _enteredPin += '$digit';
    });

    // Auto-submit only when PIN reaches max length
    if (_enteredPin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _hasError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final success =
        await ref.read(securityProvider.notifier).verifyPin(_enteredPin);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      setState(() {
        _hasError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Verifikasi PIN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Title
            Text(
              'Masukkan PIN saat ini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            // Error message
            AnimatedOpacity(
              opacity: _hasError ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                'PIN salah',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // PIN dots
            PinInputField(
              currentLength: _enteredPin.length,
              maxLength: _pinLength,
              hasError: _hasError,
            ),
            const Spacer(flex: 1),
            // Numeric keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: NumericKeypad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
