import 'package:flutter/services.dart';

/// Centralized haptic feedback utility for consistent tactile feedback
class HapticUtils {
  HapticUtils._();

  /// Light impact - for small UI interactions (toggles, chips, selections)
  static void light() => HapticFeedback.lightImpact();

  /// Medium impact - for confirmations, switches, important selections
  static void medium() => HapticFeedback.mediumImpact();

  /// Heavy impact - for destructive actions, errors, significant events
  static void heavy() => HapticFeedback.heavyImpact();

  /// Selection click - for list item selections, tab switches
  static void selection() => HapticFeedback.selectionClick();

  /// Vibrate - for errors and warnings
  static void vibrate() => HapticFeedback.vibrate();

  /// Button tap feedback
  static void buttonTap() => HapticFeedback.lightImpact();

  /// FAB tap feedback
  static void fabTap() => HapticFeedback.mediumImpact();

  /// Delete action feedback
  static void delete() => HapticFeedback.heavyImpact();

  /// Success feedback
  static void success() => HapticFeedback.mediumImpact();

  /// Error feedback
  static void error() => HapticFeedback.heavyImpact();

  /// Navigation feedback
  static void navigation() => HapticFeedback.selectionClick();

  /// Swipe action feedback
  static void swipe() => HapticFeedback.lightImpact();

  /// Long press feedback
  static void longPress() => HapticFeedback.mediumImpact();

  /// Keyboard tap feedback
  static void keyTap() => HapticFeedback.lightImpact();
}
