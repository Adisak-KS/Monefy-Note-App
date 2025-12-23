import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:monefy_note_app/pages/onboarding/widgets/glass_button.dart';

class NavigationButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onComplete;
  final bool isLoading;

  const NavigationButtons({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
    required this.onNext,
    required this.onComplete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = currentPage == 0;
    final isLastPage = currentPage == totalPages - 1;

    if (isFirstPage) {
      return Semantics(
        button: true,
        label: 'Go to next step',
        child: GlassButton(
          label: 'common.next'.tr(),
          icon: Icons.arrow_forward_rounded,
          isPrimary: true,
          onTap: onNext,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: 'Go back',
            child: GlassButton(
              label: 'common.back'.tr(),
              icon: Icons.arrow_back_rounded,
              iconFirst: true,
              isPrimary: false,
              onTap: onBack,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Semantics(
            button: true,
            label: isLastPage ? 'Start using the app' : 'Go to next step',
            child: GlassButton(
              label: isLastPage
                  ? 'onboarding.start'.tr()
                  : 'common.next'.tr(),
              icon: isLastPage
                  ? Icons.rocket_launch_rounded
                  : Icons.arrow_forward_rounded,
              isPrimary: true,
              isLoading: isLastPage && isLoading,
              onTap: isLoading ? () {} : (isLastPage ? onComplete : onNext),
            ),
          ),
        ),
      ],
    );
  }
}
