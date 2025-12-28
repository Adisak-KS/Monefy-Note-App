import 'package:flutter/material.dart';

class HomeLoadingShimmer extends StatefulWidget {
  const HomeLoadingShimmer({super.key});

  @override
  State<HomeLoadingShimmer> createState() => _HomeLoadingShimmerState();
}

class _HomeLoadingShimmerState extends State<HomeLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderShimmer(isDark),
              const SizedBox(height: 16),
              _buildBalanceCardShimmer(isDark),
              const SizedBox(height: 24),
              _buildTransactionListShimmer(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required bool isDark,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: isDark
                  ? [
                      Colors.grey[800]!,
                      Colors.grey[700]!,
                      Colors.grey[800]!,
                    ]
                  : [
                      Colors.grey[300]!,
                      Colors.grey[100]!,
                      Colors.grey[300]!,
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderShimmer(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(width: 180, height: 28, isDark: isDark),
          const SizedBox(height: 8),
          _buildShimmerBox(width: 140, height: 16, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildBalanceCardShimmer(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildShimmerBox(width: 120, height: 14, isDark: isDark),
          const SizedBox(height: 12),
          _buildShimmerBox(width: 180, height: 36, isDark: isDark),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildShimmerBox(width: 80, height: 12, isDark: isDark),
                    const SizedBox(height: 8),
                    _buildShimmerBox(width: 100, height: 18, isDark: isDark),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildShimmerBox(width: 80, height: 12, isDark: isDark),
                    const SizedBox(height: 8),
                    _buildShimmerBox(width: 100, height: 18, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListShimmer(bool isDark) {
    return Column(
      children: List.generate(
        5,
        (index) => _buildTransactionTileShimmer(isDark),
      ),
    );
  }

  Widget _buildTransactionTileShimmer(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildShimmerBox(
            width: 48,
            height: 48,
            isDark: isDark,
            borderRadius: BorderRadius.circular(24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: 120, height: 16, isDark: isDark),
                const SizedBox(height: 8),
                _buildShimmerBox(width: 80, height: 12, isDark: isDark),
              ],
            ),
          ),
          _buildShimmerBox(width: 80, height: 18, isDark: isDark),
        ],
      ),
    );
  }
}
