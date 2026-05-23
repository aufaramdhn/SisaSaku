import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/features/security/presentation/providers/security_provider.dart';
import 'package:sisasaku/features/security/presentation/widgets/numeric_keypad.dart';
import 'package:sisasaku/features/security/presentation/widgets/pin_input_field.dart';

/// Two-step PIN creation flow: enter new PIN → confirm PIN.
class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _enteredPin = '';
  String _firstPin = '';
  bool _isConfirmStep = false;
  bool _hasError = false;
  String _errorMessage = '';
  static const int _pinLength = 6;
  static const int _minPinLength = 4;

  void _onDigitPressed(int digit) {
    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _hasError = false;
      _errorMessage = '';
      _enteredPin += '$digit';
    });
  }

  void _onDeletePressed() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _onSubmit() async {
    if (_enteredPin.length < _minPinLength) {
      setState(() {
        _hasError = true;
        _errorMessage = 'PIN minimal $_minPinLength digit';
      });
      return;
    }

    if (!_isConfirmStep) {
      // Move to confirmation step
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _isConfirmStep = true;
      });
    } else {
      // Confirm step: check if PINs match
      if (_enteredPin != _firstPin) {
        setState(() {
          _hasError = true;
          _errorMessage = 'PIN tidak cocok';
          _enteredPin = '';
        });
        return;
      }

      // PINs match — save
      final success =
          await ref.read(securityProvider.notifier).setupPin(_enteredPin);
      if (success && mounted) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Gagal menyimpan PIN';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Atur PIN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Title
            Text(
              _isConfirmStep ? 'Konfirmasi PIN' : 'Masukkan PIN baru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirmStep
                  ? 'Masukkan PIN yang sama untuk konfirmasi'
                  : 'Buat PIN $_minPinLength–$_pinLength digit',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            // Error message
            AnimatedOpacity(
              opacity: _hasError ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                _errorMessage,
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
            const SizedBox(height: 16),
            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _enteredPin.length >= _minPinLength ? _onSubmit : null,
                  child: Text(_isConfirmStep ? 'Konfirmasi' : 'Lanjut'),
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
