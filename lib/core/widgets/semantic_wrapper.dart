import 'package:flutter/material.dart';

/// A wrapper that adds semantic information for accessibility
class SemanticWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isHeader;
  final bool isLink;
  final bool isEnabled;
  final bool isSelected;
  final bool isChecked;
  final bool excludeSemantics;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SemanticWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isHeader = false,
    this.isLink = false,
    this.isEnabled = true,
    this.isSelected = false,
    this.isChecked = false,
    this.excludeSemantics = false,
    this.onTap,
    this.onLongPress,
  });

  /// Factory for button semantics
  factory SemanticWrapper.button({
    Key? key,
    required Widget child,
    required String label,
    String? hint,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return SemanticWrapper(
      key: key,
      label: label,
      hint: hint,
      isButton: true,
      isEnabled: isEnabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Factory for header semantics
  factory SemanticWrapper.header({
    Key? key,
    required Widget child,
    required String label,
  }) {
    return SemanticWrapper(
      key: key,
      label: label,
      isHeader: true,
      child: child,
    );
  }

  /// Factory for transaction item semantics
  factory SemanticWrapper.transaction({
    Key? key,
    required Widget child,
    required String category,
    required String amount,
    required bool isExpense,
    String? note,
  }) {
    final type = isExpense ? 'Expense' : 'Income';
    final noteText = note != null && note.isNotEmpty ? ', $note' : '';
    return SemanticWrapper(
      key: key,
      label: '$type: $amount for $category$noteText',
      hint: 'Double tap to edit, swipe to delete',
      isButton: true,
      child: child,
    );
  }

  /// Factory for balance display semantics
  factory SemanticWrapper.balance({
    Key? key,
    required Widget child,
    required String amount,
    required String label,
  }) {
    return SemanticWrapper(
      key: key,
      label: '$label: $amount',
      child: child,
    );
  }

  /// Factory for navigation item semantics
  factory SemanticWrapper.navigation({
    Key? key,
    required Widget child,
    required String label,
    bool isSelected = false,
  }) {
    return SemanticWrapper(
      key: key,
      label: label,
      hint: isSelected ? 'Currently selected' : 'Double tap to navigate',
      isButton: true,
      isSelected: isSelected,
      child: child,
    );
  }

  /// Factory for toggle/switch semantics
  factory SemanticWrapper.toggle({
    Key? key,
    required Widget child,
    required String label,
    required bool isChecked,
    String? hint,
  }) {
    return SemanticWrapper(
      key: key,
      label: label,
      hint: hint ?? 'Double tap to toggle',
      isChecked: isChecked,
      isButton: true,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      link: isLink,
      enabled: isEnabled,
      selected: isSelected,
      checked: isChecked ? true : null,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }
}

/// Extension to easily add semantics to widgets
extension SemanticsExtension on Widget {
  Widget withSemantics({
    String? label,
    String? hint,
    bool isButton = false,
    bool isHeader = false,
  }) {
    return SemanticWrapper(
      label: label,
      hint: hint,
      isButton: isButton,
      isHeader: isHeader,
      child: this,
    );
  }

  Widget withButtonSemantics(String label, {String? hint}) {
    return SemanticWrapper.button(
      label: label,
      hint: hint,
      child: this,
    );
  }

  Widget withHeaderSemantics(String label) {
    return SemanticWrapper.header(
      label: label,
      child: this,
    );
  }
}
