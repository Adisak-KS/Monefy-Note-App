import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/pages/splash/bloc/splash_cubit.dart';
import 'package:monefy_note_app/pages/splash/bloc/splash_state.dart';
import 'package:monefy_note_app/pages/splash/widgets/gradient_background.dart';
import 'package:monefy_note_app/pages/splash/widgets/shimmer_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Check if user has reduced motion enabled
  bool get _reduceMotion =>
      MediaQuery.of(context).disableAnimations ||
      MediaQuery.of(context).boldText;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit()..initialize(),
      child: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashLoaded) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: GradientBackground(
              child: SafeArea(
                child: Semantics(
                  label: 'app.name'.tr(),
                  hint: 'app.tagline'.tr(),
                  child: Stack(
                    children: [
                      // Main content
                      _buildMainContent(context, state),
                      // Skip button (top right)
                      if (state is SplashLoading) _buildSkipButton(context),
                      // Offline indicator (top center)
                      if (state is SplashLoading && state.isOffline)
                        _buildOfflineIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, SplashState state) {
    // Error state
    if (state is SplashError) {
      return _buildErrorState(context, state.message);
    }

    // Loading state
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final isDesktop = constraints.maxWidth > 600;

        // Responsive sizing
        final logoSize = isLandscape
            ? min(constraints.maxHeight * 0.4, 120.0)
            : isDesktop
            ? 160.0
            : min(constraints.maxWidth * 0.35, 140.0);
        final titleSize = isDesktop
            ? 32.0
            : isLandscape
            ? 22.0
            : 24.0;
        final taglineSize = isDesktop ? 16.0 : 14.0;
        final loadingSize = isDesktop ? 14.0 : 12.0;

        // Get progress from state (keep at 100% when loaded to avoid flicker)
        final progress = state is SplashLoading ? state.progress : 1.0;

        if (isLandscape && !isDesktop) {
          return _buildLandscapeLayout(
            logoSize: logoSize,
            titleSize: titleSize,
            taglineSize: taglineSize,
            loadingSize: loadingSize,
            progress: progress,
          );
        }

        return _buildPortraitLayout(
          logoSize: logoSize,
          titleSize: titleSize,
          taglineSize: taglineSize,
          loadingSize: loadingSize,
          spacing: isDesktop ? 32.0 : 24.0,
          progress: progress,
        );
      },
    );
  }

  Widget _buildPortraitLayout({
    required double logoSize,
    required double titleSize,
    required double taglineSize,
    required double loadingSize,
    required double spacing,
    required double progress,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildLogo(logoSize),
            SizedBox(height: spacing),
            _buildTitle(titleSize),
            const SizedBox(height: 8),
            _buildTagline(taglineSize),
            const Spacer(flex: 2),
            _buildLoading(loadingSize, progress: progress),
            SizedBox(height: spacing),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout({
    required double logoSize,
    required double titleSize,
    required double taglineSize,
    required double loadingSize,
    required double progress,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(logoSize),
            const SizedBox(width: 40),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(titleSize, align: TextAlign.left),
                  const SizedBox(height: 8),
                  _buildTagline(taglineSize, align: TextAlign.left),
                  const SizedBox(height: 24),
                  _buildLoading(
                    loadingSize,
                    horizontal: true,
                    progress: progress,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    // Skip animation if reduced motion is enabled
    if (_reduceMotion) {
      return Semantics(
        image: true,
        label: 'Monefy Note Logo',
        child: ShimmerLogo(size: size),
      );
    }

    return Semantics(
      image: true,
      label: 'Monefy Note Logo',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: ShimmerLogo(size: size),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(double fontSize, {TextAlign align = TextAlign.center}) {
    final titleWidget = Text(
      'app.name'.tr(),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
      ),
      textAlign: align,
    );

    if (_reduceMotion) {
      return Semantics(header: true, child: titleWidget);
    }

    return Semantics(
      header: true,
      child: FadeTransition(opacity: _fadeAnimation, child: titleWidget),
    );
  }

  Widget _buildTagline(double fontSize, {TextAlign align = TextAlign.center}) {
    final taglineWidget = Text(
      'app.tagline'.tr(),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.8),
        fontSize: fontSize,
      ),
      textAlign: align,
    );

    if (_reduceMotion) {
      return taglineWidget;
    }

    return FadeTransition(opacity: _fadeAnimation, child: taglineWidget);
  }

  Widget _buildLoading(
    double fontSize, {
    bool horizontal = false,
    required double progress,
  }) {
    final progressPercent = (progress * 100).toInt();
    final progressText = '$progressPercent%';

    final content = horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress indicator
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                progressText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: fontSize,
                ),
              ),
            ],
          )
        : Column(
            children: [
              // Circular progress with percentage
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      color: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      strokeWidth: 3,
                    ),
                    Text(
                      progressText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'common.loading'.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: fontSize,
                ),
              ),
            ],
          );

    if (_reduceMotion) {
      return Semantics(
        label: 'Loading $progressPercent percent',
        child: content,
      );
    }

    return Semantics(
      label: 'Loading $progressPercent percent',
      child: FadeTransition(opacity: _fadeAnimation, child: content),
    );
  }

  Widget _buildSkipButton(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Semantics(
        button: true,
        label: 'common.skip'.tr(),
        child: TextButton(
          onPressed: () {
            context.read<SplashCubit>().skip();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text('common.skip'.tr(), style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(
        child: Semantics(
          liveRegion: true,
          label: 'common.offline'.tr(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'common.offline'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(
                'common.error'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: 'common.retry'.tr(),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<SplashCubit>().initialize();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('common.retry'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
