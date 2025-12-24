import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late final AnimationController _gradientController;
  late final AnimationController _bubbleController;
  late final List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      duration: const Duration(seconds: 12),
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
    return ListenableBuilder(
      listenable: Listenable.merge([_gradientController, _bubbleController]),
      builder: (context, child) => _buildBackground(child!),
      child: widget.child,
    );
  }

  Widget _buildBackground(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        isDark ? AppColors.defaultGradientDark : AppColors.defaultGradientLight;

    return SizedBox.expand(
      child: DecoratedBox(
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
            ..._bubbles.map((bubble) => _buildBubble(bubble)),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(Bubble bubble) {
    final progress = (_bubbleController.value + bubble.offset) % 1.0;
    final yPos = 1.0 - progress;
    final screenSize = MediaQuery.of(context).size;

    final xWobble = sin(progress * pi * 2 * bubble.wobbleFrequency) * 20;

    return Positioned(
      left: bubble.x * screenSize.width + xWobble,
      top: yPos * screenSize.height * 1.2 - 50,
      child: Opacity(
        opacity: bubble.opacity * (1 - (progress * 0.5)),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: bubble.size,
              height: bubble.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blur = 10,
    this.opacity = 0.1,
  });

  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
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
  final double wobbleFrequency;

  Bubble({
    required this.x,
    required this.size,
    required this.opacity,
    required this.offset,
    required this.wobbleFrequency,
  });

  factory Bubble.random() {
    final random = Random();
    return Bubble(
      x: random.nextDouble(),
      size: 25 + random.nextDouble() * 60,
      opacity: 0.15 + random.nextDouble() * 0.25,
      offset: random.nextDouble(),
      wobbleFrequency: 1 + random.nextDouble() * 2,
    );
  }
}
