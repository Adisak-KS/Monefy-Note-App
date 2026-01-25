import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Custom page transitions for consistent navigation experience
class AppPageTransitions {
  AppPageTransitions._();

  /// Fade transition - good for tab switching and overlays
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppDurations.pageTransition,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide up transition - good for modals and sheets
  static CustomTransitionPage<T> slideUp<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppDurations.pageTransition,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Slide from right transition - standard navigation
  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppDurations.pageTransition,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  /// Scale transition - good for detail pages
  static CustomTransitionPage<T> scale<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppDurations.pageTransition,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis horizontal - Material 3 style
  static CustomTransitionPage<T> sharedAxisHorizontal<T>({
    required LocalKey key,
    required Widget child,
    Duration duration = AppDurations.pageTransition,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        // Outgoing page fades and moves left
        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnimation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.3, 0),
              ).animate(secondaryCurved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 1, end: 0).animate(secondaryCurved),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
