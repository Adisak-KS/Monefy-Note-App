import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityNumpad extends StatelessWidget {
  const SecurityNumpad({
    super.key,
    required this.onNumberTap,
    required this.onDeleteTap,
    this.onClearTap,
    this.showClear = true,
  });

  final void Function(String number) onNumberTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onClearTap;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers
          .map((number) => _NumpadButton(
                label: number,
                onTap: () => onNumberTap(number),
              ))
          .toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (showClear && onClearTap != null)
          _NumpadButton(
            label: 'C',
            onTap: onClearTap!,
            isAction: true,
          )
        else
          const SizedBox(width: 72, height: 72),
        _NumpadButton(
          label: '0',
          onTap: () => onNumberTap('0'),
        ),
        _NumpadButton(
          icon: Icons.backspace_outlined,
          onTap: onDeleteTap,
          isAction: true,
        ),
      ],
    );
  }
}

class _NumpadButton extends StatefulWidget {
  const _NumpadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.isAction = false,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isAction;

  @override
  State<_NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<_NumpadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: widget.isAction
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 26,
                  )
                : Text(
                    widget.label ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
