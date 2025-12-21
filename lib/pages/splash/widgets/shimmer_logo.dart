import 'package:flutter/material.dart';
import 'package:monefy_note_app/pages/splash/widgets/monefy_logo.dart';

class ShimmerLogo extends StatefulWidget {
  final double size;

  const ShimmerLogo({super.key, this.size = 140});

  @override
  State<ShimmerLogo> createState() => _ShimmerLogoState();
}

class _ShimmerLogoState extends State<ShimmerLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.2, end: 0.5).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: _animation.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: MonefyLogo(size: widget.size),
    );
  }
}
