import 'package:flutter/material.dart';
import 'package:monefy_note_app/pages/security-setup/widgets/security_numpad.dart';

class PinInputWidget extends StatefulWidget {
  const PinInputWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onComplete,
    this.errorMessage,
    this.onErrorClear,
  });

  final String title;
  final String subtitle;
  final void Function(String pin) onComplete;
  final String? errorMessage;
  final VoidCallback? onErrorClear;

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger shake animation when error appears
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
        setState(() => _pin = '');
      });
    }
  }

  void _onNumberTap(String number) {
    if (_pin.length < 6) {
      widget.onErrorClear?.call();
      setState(() => _pin += number);
      if (_pin.length == 6) {
        widget.onComplete(_pin);
      }
    }
  }

  void _onDeleteTap() {
    if (_pin.isNotEmpty) {
      widget.onErrorClear?.call();
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onClearTap() {
    widget.onErrorClear?.call();
    setState(() => _pin = '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          widget.subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // PIN Dots
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shake = _shakeAnimation.value * 10;
            return Transform.translate(
              offset: Offset(
                shake * ((_shakeAnimation.value * 10).toInt() % 2 == 0 ? 1 : -1),
                0,
              ),
              child: child,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final isFilled = index < _pin.length;
              final hasError = widget.errorMessage != null;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? (hasError ? Colors.red : Colors.white)
                        : Colors.transparent,
                    border: Border.all(
                      color: hasError
                          ? Colors.red
                          : Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // Error message
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          child: widget.errorMessage != null
              ? Center(
                  child: Text(
                    widget.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        // Numpad
        SecurityNumpad(
          onNumberTap: _onNumberTap,
          onDeleteTap: _onDeleteTap,
          onClearTap: _onClearTap,
        ),
      ],
    );
  }
}
