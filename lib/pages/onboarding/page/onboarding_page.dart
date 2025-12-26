import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:monefy_note_app/core/services/preferences_service.dart';
import 'package:monefy_note_app/core/theme/app_colors.dart';
import 'package:monefy_note_app/core/theme/theme_cubit.dart';
import 'package:monefy_note_app/pages/onboarding/bloc/onboarding_cubit.dart';
import 'package:monefy_note_app/pages/onboarding/bloc/onboarding_state.dart';
import 'package:monefy_note_app/pages/onboarding/widgets/widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final OnboardingCubit _cubit;
  late final PageController _pageController;
  late final AnimationController _gradientController;
  late final AnimationController _bubbleController;
  late final List<_Bubble> _bubbles;

  bool _isInitialized = false;
  int _currentPage = 0;
  double _scrollProgress = 0.0;
  bool _isCompleting = false;

  static const _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onScroll);

    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _bubbles = List.generate(6, (_) => _Bubble.random());
  }

  void _onScroll() {
    if (_pageController.hasClients && _pageController.page != null) {
      setState(() {
        _scrollProgress = _pageController.page!;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _cubit = OnboardingCubit(
        prefsService: PreferencesService(),
        themeCubit: context.read<ThemeCubit>(),
        initialLocale: context.locale,
      );
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _gradientController.dispose();
    _bubbleController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _onComplete() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    final selectedLocale = _cubit.state.selectedLocale;
    if (mounted) {
      context.setLocale(selectedLocale);
    }

    _showConfettiBurst();

    await Future.delayed(const Duration(milliseconds: 800));

    await _cubit.complete();
    if (mounted) {
      // Check if privacy policy is accepted
      final prefsService = PreferencesService();
      final accepted = await prefsService.isPrivacyPolicyAccepted();

      if (mounted) {
        if (accepted) {
          context.go('/sign-in');
        } else {
          context.go('/privacy-policy');
        }
      }
    }
  }

  void _showConfettiBurst() {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) =>
          ConfettiBurstOverlay(onComplete: () => entry.remove()),
    );

    overlay.insert(entry);
  }

  void _onSelectWithHaptic(VoidCallback action) {
    HapticFeedback.selectionClick();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Semantics(
          label: 'Onboarding screen',
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _gradientController,
              _bubbleController,
            ]),
            builder: (context, child) {
              return _buildBackground(child!);
            },
            child: SafeArea(
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  return Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Semantics(
                                  label:
                                      'Page ${_currentPage + 1} of $_totalPages',
                                  child: PageIndicator(
                                    currentPage: _currentPage,
                                    totalPages: _totalPages,
                                  ),
                                ),
                                if (_currentPage < _totalPages - 1)
                                  Semantics(
                                    button: true,
                                    label: 'Skip to last page',
                                    child: SkipButton(
                                      label: 'common.skip'.tr(),
                                      onTap: _skipToLastPage,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _totalPages,
                              onPageChanged: (page) {
                                HapticFeedback.selectionClick();
                                setState(() => _currentPage = page);
                              },
                              itemBuilder: (context, index) {
                                final pageOffset = _scrollProgress - index;
                                final absOffset = pageOffset.abs().clamp(
                                  0.0,
                                  1.0,
                                );
                                final scale = 1.0 - (absOffset * 0.1);
                                final opacity = 1.0 - (absOffset * 0.5);
                                final translateX = pageOffset * 30;

                                Widget page;
                                switch (index) {
                                  case 0:
                                    page = LanguagePage(
                                      selectedLocale: state.selectedLocale,
                                      onSelect: (l) => _onSelectWithHaptic(
                                        () => _cubit.selectLocale(l),
                                      ),
                                    );
                                    break;
                                  case 1:
                                    page = ThemePage(
                                      selectedTheme: state.selectedTheme,
                                      onSelect: (t) => _onSelectWithHaptic(
                                        () => _cubit.selectTheme(t),
                                      ),
                                    );
                                    break;
                                  case 2:
                                  default:
                                    page = const ReadyPage();
                                }

                                return Transform.translate(
                                  offset: Offset(translateX, 0),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: opacity.clamp(0.0, 1.0),
                                      child: page,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_currentPage < _totalPages - 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swipe_rounded,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'onboarding.swipe_hint'.tr(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            child: NavigationButtons(
                              currentPage: _currentPage,
                              totalPages: _totalPages,
                              isLoading: _isCompleting,
                              onBack: () {
                                HapticFeedback.lightImpact();
                                _previousPage();
                              },
                              onNext: () {
                                HapticFeedback.lightImpact();
                                _nextPage();
                              },
                              onComplete: () {
                                HapticFeedback.mediumImpact();
                                _onComplete();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? AppColors.defaultGradientDark
        : AppColors.defaultGradientLight;

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
        children: [..._bubbles.map((bubble) => _buildBubble(bubble)), child],
      ),
    );
  }

  Widget _buildBubble(_Bubble bubble) {
    final progress = (_bubbleController.value + bubble.offset) % 1.0;
    final yPos = 1.0 - progress;
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: bubble.x * screenSize.width,
      top: yPos * screenSize.height * 1.2 - 50,
      child: Opacity(
        opacity: bubble.opacity * (1 - (progress * 0.5)),
        child: Container(
          width: bubble.size,
          height: bubble.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble {
  final double x;
  final double size;
  final double opacity;
  final double offset;

  _Bubble({
    required this.x,
    required this.size,
    required this.opacity,
    required this.offset,
  });

  factory _Bubble.random() {
    final random = Random();
    return _Bubble(
      x: random.nextDouble(),
      size: 20 + random.nextDouble() * 50,
      opacity: 0.2 + random.nextDouble() * 0.3,
      offset: random.nextDouble(),
    );
  }
}
