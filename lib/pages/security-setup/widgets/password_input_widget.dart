import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordInputWidget extends StatefulWidget {
  const PasswordInputWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onComplete,
    this.errorMessage,
    this.onErrorClear,
  });

  final String title;
  final String subtitle;
  final void Function(String password) onComplete;
  final String? errorMessage;
  final VoidCallback? onErrorClear;

  @override
  State<PasswordInputWidget> createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscureText = true;
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

    // Auto focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PasswordInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
        _controller.clear();
      });
    }
  }

  void _onSubmit() {
    final password = _controller.text;
    if (password.length >= 6) {
      HapticFeedback.lightImpact();
      widget.onComplete(password);
    }
  }

  String _getStrengthLabel(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Too short';

    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (strength <= 2) return 'Weak';
    if (strength <= 3) return 'Medium';
    return 'Strong';
  }

  Color _getStrengthColor(String label) {
    switch (label) {
      case 'Too short':
        return Colors.red;
      case 'Weak':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strengthLabel = _getStrengthLabel(_controller.text);
    final strengthColor = _getStrengthColor(strengthLabel);

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
        // Password field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final shake = _shakeAnimation.value * 10;
              return Transform.translate(
                offset: Offset(
                  shake *
                      ((_shakeAnimation.value * 10).toInt() % 2 == 0 ? 1 : -1),
                  0,
                ),
                child: child,
              );
            },
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              obscureText: _obscureText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: widget.errorMessage != null
                        ? Colors.red
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: widget.errorMessage != null
                        ? Colors.red
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: widget.errorMessage != null
                        ? Colors.red
                        : Colors.white,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                ),
              ),
              onChanged: (_) {
                widget.onErrorClear?.call();
                setState(() {});
              },
              onSubmitted: (_) => _onSubmit(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Strength indicator
        if (_controller.text.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: strengthColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strengthLabel,
                style: TextStyle(
                  color: strengthColor,
                  fontSize: 14,
                ),
              ),
            ],
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
        // Continue button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _controller.text.length >= 6 ? _onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
