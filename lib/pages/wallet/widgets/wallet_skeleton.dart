import 'package:flutter/material.dart';

class WalletSkeleton extends StatefulWidget {
  const WalletSkeleton({super.key});

  @override
  State<WalletSkeleton> createState() => _WalletSkeletonState();
}

class _WalletSkeletonState extends State<WalletSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // Header skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    _buildShimmer(
                      width: 48,
                      height: 48,
                      borderRadius: 16,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmer(
                            width: 100,
                            height: 14,
                            borderRadius: 4,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 8),
                          _buildShimmer(
                            width: 150,
                            height: 18,
                            borderRadius: 4,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    _buildShimmer(
                      width: 36,
                      height: 36,
                      borderRadius: 12,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Balance card skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildShimmer(
                  width: double.infinity,
                  height: 160,
                  borderRadius: 20,
                  isDark: isDark,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Statistics card skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildShimmer(
                  width: double.infinity,
                  height: 100,
                  borderRadius: 16,
                  isDark: isDark,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Section header skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildShimmer(
                  width: 120,
                  height: 20,
                  borderRadius: 4,
                  isDark: isDark,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Wallet group header skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildShimmer(
                  width: double.infinity,
                  height: 56,
                  borderRadius: 16,
                  isDark: isDark,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // Wallet items skeleton
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: _buildWalletItemSkeleton(isDark),
                ),
                childCount: 3,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // Another group skeleton
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildShimmer(
                  width: double.infinity,
                  height: 56,
                  borderRadius: 16,
                  isDark: isDark,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: _buildWalletItemSkeleton(isDark),
                ),
                childCount: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWalletItemSkeleton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildShimmer(
            width: 44,
            height: 44,
            borderRadius: 14,
            isDark: isDark,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(
                  width: 100,
                  height: 14,
                  borderRadius: 4,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _buildShimmer(
                  width: 60,
                  height: 12,
                  borderRadius: 4,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildShimmer(
                width: 80,
                height: 16,
                borderRadius: 4,
                isDark: isDark,
              ),
              const SizedBox(height: 4),
              _buildShimmer(
                width: 50,
                height: 10,
                borderRadius: 4,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer({
    required double width,
    required double height,
    required double borderRadius,
    required bool isDark,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  Colors.black.withValues(alpha: 0.04),
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.04),
                ],
        ),
      ),
    );
  }
}
