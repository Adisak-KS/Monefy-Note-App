import 'dart:math';
import 'package:flutter/material.dart';

// Confetti data class
class Confetti {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;

  Confetti({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
  });

  factory Confetti.random() {
    final random = Random();
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];
    return Confetti(
      x: random.nextDouble(),
      speed: 0.5 + random.nextDouble() * 0.5,
      size: 6 + random.nextDouble() * 8,
      color: colors[random.nextInt(colors.length)],
      rotation: random.nextDouble() * 360,
    );
  }
}

// Burst confetti data
class BurstConfetti {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;

  BurstConfetti({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });

  factory BurstConfetti.random() {
    final random = Random();
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.teal,
    ];
    return BurstConfetti(
      angle: -pi / 2 + (random.nextDouble() - 0.5) * pi * 0.8,
      speed: 300 + random.nextDouble() * 400,
      size: 8 + random.nextDouble() * 10,
      color: colors[random.nextInt(colors.length)],
      rotationSpeed: (random.nextDouble() - 0.5) * 20,
    );
  }
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<Confetti> confettiList;
  final double progress;

  ConfettiPainter({required this.confettiList, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final confetti in confettiList) {
      final y =
          (progress * confetti.speed * size.height * 2) % (size.height * 1.5);
      final x = confetti.x * size.width;
      final opacity = (1 - (y / size.height)).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = confetti.color.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(confetti.rotation + progress * 10);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}

// Burst confetti painter
class BurstConfettiPainter extends CustomPainter {
  final List<BurstConfetti> confettiList;
  final double progress;

  BurstConfettiPainter({required this.confettiList, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final startY = size.height * 0.85;
    final gravity = 800.0;

    for (final confetti in confettiList) {
      final time = progress * 1.5;
      final vx = cos(confetti.angle) * confetti.speed;
      final vy = sin(confetti.angle) * confetti.speed;

      final x = centerX + vx * time;
      final y = startY + vy * time + 0.5 * gravity * time * time;

      if (y > size.height + 50) continue;

      final opacity = (1 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = confetti.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(confetti.rotationSpeed * time);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant BurstConfettiPainter oldDelegate) => true;
}

// Confetti Burst Overlay for Get Started button
class ConfettiBurstOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ConfettiBurstOverlay({super.key, required this.onComplete});

  @override
  State<ConfettiBurstOverlay> createState() => _ConfettiBurstOverlayState();
}

class _ConfettiBurstOverlayState extends State<ConfettiBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<BurstConfetti> _confettiList;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _confettiList = List.generate(50, (_) => BurstConfetti.random());

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: BurstConfettiPainter(
              confettiList: _confettiList,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}
