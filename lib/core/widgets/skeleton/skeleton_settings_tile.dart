import 'package:flutter/material.dart';
import 'shimmer_wrapper.dart';
import 'skeleton_box.dart';

class SkeletonSettingsTile extends StatelessWidget {
  const SkeletonSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ShimmerWrapper(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SkeletonCircle(size: 40),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      width: 100,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    SkeletonBox(
                      width: 150,
                      height: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              SkeletonBox(
                width: 24,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonSettingsSection extends StatelessWidget {
  final int tileCount;

  const SkeletonSettingsSection({
    super.key,
    this.tileCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          ShimmerWrapper(
            child: SkeletonBox(
              width: 80,
              height: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // Tiles container
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: List.generate(
                tileCount,
                (index) => const SkeletonSettingsTile(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonSettingsPage extends StatelessWidget {
  const SkeletonSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          SkeletonSettingsSection(tileCount: 2),
          SkeletonSettingsSection(tileCount: 2),
          SkeletonSettingsSection(tileCount: 2),
          SkeletonSettingsSection(tileCount: 3),
          SkeletonSettingsSection(tileCount: 4),
        ],
      ),
    );
  }
}
