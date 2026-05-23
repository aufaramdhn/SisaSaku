import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/features/security/presentation/providers/security_provider.dart';
import 'package:sisasaku/features/security/presentation/widgets/numeric_keypad.dart';
import 'package:sisasaku/features/security/presentation/widgets/pin_input_field.dart';

/// Full-screen lock screen overlay with PIN pad and optional biometric prompt.
/// Blocks back navigation with PopScope.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  bool _hasError = false;
  bool _biometricAttempted = false;
  static const int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptBiometric();
    });
  }

  Future<void> _attemptBiometric() async {
    if (_biometricAttempted) return;
    _biometricAttempted = true;

    final securityState = ref.read(securityProvider);
    if (!securityState.biometricEnabled) return;

    final success =
        await ref.read(securityProvider.notifier).authenticateWithBiometric();
    if (success && mounted) {
      ref.read(securityProvider.notifier).hideLockScreen();
    }
  }

  void _onDigitPressed(int digit) {
    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _hasError = false;
      _enteredPin += '$digit';
    });

    // Auto-submit only when PIN reaches max length (6 digits)
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
      ref.read(securityProvider.notifier).hideLockScreen();
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

    return PopScope(
      canPop: false,
      child: Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Lock icon
              Icon(
                Icons.lock_outline,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Masukkan PIN',
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
              const SizedBox(height: 16),
              // Biometric button (if enabled)
              if (ref.watch(securityProvider).biometricEnabled)
                TextButton.icon(
                  onPressed: () {
                    _biometricAttempted = false;
                    _attemptBiometric();
                  },
                  icon: Icon(
                    Icons.fingerprint,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    'Gunakan Biometrik',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
