import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => AuthTextFieldState();
}

class AuthTextFieldState extends State<AuthTextField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;
  String? _errorText;
  bool _hasInteracted = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    _shakeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_hasInteracted) return;

    final value = widget.controller?.text;
    final newError = widget.validator?.call(value);

    if (_errorText != newError) {
      setState(() => _errorText = newError);
    }
  }

  void _validateRealTime(String value) {
    // เริ่ม validate ทันทีเมื่อพิมพ์
    setState(() => _hasInteracted = true);

    final newError = widget.validator?.call(value);

    if (_errorText != newError) {
      final hadError = _errorText != null;
      setState(() => _errorText = newError);

      // Shake เมื่อ error ปรากฏครั้งแรกเท่านั้น
      if (newError != null && !hadError) {
        shake();
      }
    }
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: '${widget.label}${_errorText != null ? ', Error: $_errorText' : ''}',
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white.withValues(alpha: _isFocused ? 1.0 : 0.9),
                  fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                ),
            child: Text(widget.label),
          ),
          const SizedBox(height: 8),
          Focus(
            onFocusChange: (hasFocus) {
              setState(() => _isFocused = hasFocus);
              if (!hasFocus && !_hasInteracted && widget.controller?.text.isNotEmpty == true) {
                _validateRealTime(widget.controller!.text);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..setEntry(0, 0, _isFocused ? 1.02 : 1.0)
                ..setEntry(1, 1, _isFocused ? 1.02 : 1.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: _isFocused ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _errorText != null
                      ? Colors.red.shade400
                      : _isFocused
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.2),
                  width: _errorText != null ? 2 : (_isFocused ? 2 : 1.5),
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.isPassword && _obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onChanged: _validateRealTime,
                validator: (value) {
                  final error = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _errorText != error) {
                      setState(() {
                        _errorText = error;
                        _hasInteracted = true;
                      });
                      if (error != null) shake();
                    }
                  });
                  return error;
                },
                onFieldSubmitted: widget.onSubmitted,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                  prefixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.prefixIcon,
                      color: Colors.white.withValues(alpha: _isFocused ? 1.0 : 0.7),
                      size: 22,
                    ),
                  ),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              key: ValueKey(_obscureText),
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 22,
                            ),
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _errorText != null
                ? Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.shade400.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorText!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      ),
    );
  }
}
