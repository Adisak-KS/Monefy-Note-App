import 'dart:math';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _bubbleController;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();

    // Animated gradient
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    // Floating bubbles
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _bubbles = List.generate(8, (_) => Bubble.random());
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? AppColors.defaultGradientDark
        : AppColors.defaultGradientLight;

    return AnimatedBuilder(
      animation: Listenable.merge([_gradientController, _bubbleController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + _gradientController.value * 0.5,
                -1 + _gradientController.value * 0.5,
              ),
              end: Alignment(
                1 - _gradientController.value * 0.5,
                1 - _gradientController.value * 0.5,
              ),
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              // Floating bubbles
              ..._bubbles.map((bubble) => _buildBubble(bubble)),
              // Content
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  Widget _buildBubble(Bubble bubble) {
    final progress = (_bubbleController.value + bubble.offset) % 1.0;
    final yPos = 1.0 - progress;

    return Positioned(
      left: bubble.x * MediaQuery.of(context).size.width,
      top: yPos * MediaQuery.of(context).size.height * 1.2 - 50,
      child: Opacity(
        opacity: bubble.opacity * (1 - (progress * 0.5)),
        child: Container(
          width: bubble.size,
          height: bubble.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class Bubble {
  final double x;
  final double size;
  final double opacity;
  final double offset;

  Bubble({
    required this.x,
    required this.size,
    required this.opacity,
    required this.offset,
  });

  factory Bubble.random() {
    final random = Random();
    return Bubble(
      x: random.nextDouble(),
      size: 20 + random.nextDouble() * 40,
      opacity: 0.3 + random.nextDouble() * 0.4,
      offset: random.nextDouble(),
    );
  }
}
