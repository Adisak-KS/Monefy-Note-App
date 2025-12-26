import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatternInputWidget extends StatefulWidget {
  const PatternInputWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onComplete,
    this.errorMessage,
    this.onErrorClear,
  });

  final String title;
  final String subtitle;
  final void Function(List<int> pattern) onComplete;
  final String? errorMessage;
  final VoidCallback? onErrorClear;

  @override
  State<PatternInputWidget> createState() => _PatternInputWidgetState();
}

class _PatternInputWidgetState extends State<PatternInputWidget>
    with SingleTickerProviderStateMixin {
  List<int> _pattern = [];
  Offset? _currentPosition;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  final List<Offset> _dotPositions = [];
  final double _dotSize = 20;
  final double _gridSize = 280;
  final double _hitRadius = 40;

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

    // Calculate dot positions
    _calculateDotPositions();
  }

  void _calculateDotPositions() {
    final spacing = _gridSize / 3;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        _dotPositions.add(Offset(
          spacing / 2 + col * spacing,
          spacing / 2 + row * spacing,
        ));
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PatternInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
        setState(() => _pattern = []);
      });
    }
  }

  int? _getDotAtPosition(Offset position) {
    for (int i = 0; i < _dotPositions.length; i++) {
      final distance = (position - _dotPositions[i]).distance;
      if (distance < _hitRadius) {
        return i;
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails details) {
    widget.onErrorClear?.call();
    final localPosition = details.localPosition;
    final dotIndex = _getDotAtPosition(localPosition);
    if (dotIndex != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _pattern = [dotIndex];
        _currentPosition = localPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_pattern.isEmpty) return;

    final localPosition = details.localPosition;
    setState(() => _currentPosition = localPosition);

    final dotIndex = _getDotAtPosition(localPosition);
    if (dotIndex != null && !_pattern.contains(dotIndex)) {
      HapticFeedback.selectionClick();
      setState(() => _pattern.add(dotIndex));
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _currentPosition = null);
    if (_pattern.length >= 4) {
      widget.onComplete(_pattern);
    } else if (_pattern.isNotEmpty) {
      HapticFeedback.heavyImpact();
      // Clear pattern if less than 4 dots
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _pattern = []);
        }
      });
    }
  }

  void _clearPattern() {
    widget.onErrorClear?.call();
    setState(() => _pattern = []);
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
        // Pattern Grid
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
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              width: _gridSize,
              height: _gridSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: CustomPaint(
                painter: _PatternPainter(
                  dotPositions: _dotPositions,
                  pattern: _pattern,
                  currentPosition: _currentPosition,
                  dotSize: _dotSize,
                  hasError: widget.errorMessage != null,
                ),
              ),
            ),
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
              : _pattern.isNotEmpty && _pattern.length < 4
                  ? Center(
                      child: Text(
                        'Connect at least 4 dots',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
        // Clear button
        TextButton.icon(
          onPressed: _pattern.isNotEmpty ? _clearPattern : null,
          icon: Icon(
            Icons.refresh,
            color: _pattern.isNotEmpty
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
          label: Text(
            'Clear',
            style: TextStyle(
              color: _pattern.isNotEmpty
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({
    required this.dotPositions,
    required this.pattern,
    required this.currentPosition,
    required this.dotSize,
    required this.hasError,
  });

  final List<Offset> dotPositions;
  final List<int> pattern;
  final Offset? currentPosition;
  final double dotSize;
  final bool hasError;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final selectedDotPaint = Paint()
      ..color = hasError ? Colors.red : Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = hasError
          ? Colors.red.withValues(alpha: 0.7)
          : Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw lines between connected dots
    if (pattern.length > 1) {
      final path = Path();
      path.moveTo(dotPositions[pattern[0]].dx, dotPositions[pattern[0]].dy);
      for (int i = 1; i < pattern.length; i++) {
        path.lineTo(dotPositions[pattern[i]].dx, dotPositions[pattern[i]].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Draw line to current position
    if (pattern.isNotEmpty && currentPosition != null) {
      canvas.drawLine(
        dotPositions[pattern.last],
        currentPosition!,
        linePaint..color = Colors.white.withValues(alpha: 0.5),
      );
    }

    // Draw dots
    for (int i = 0; i < dotPositions.length; i++) {
      final isSelected = pattern.contains(i);
      final paint = isSelected ? selectedDotPaint : dotPaint;

      // Outer circle
      canvas.drawCircle(
        dotPositions[i],
        dotSize / 2,
        paint,
      );

      // Inner highlight for selected dots
      if (isSelected) {
        canvas.drawCircle(
          dotPositions[i],
          dotSize / 4,
          Paint()
            ..color = hasError
                ? Colors.red.shade300
                : Colors.white.withValues(alpha: 0.8),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.hasError != hasError;
  }
}
