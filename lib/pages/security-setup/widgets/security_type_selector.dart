import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monefy_note_app/core/models/security_type.dart';

class SecurityTypeSelector extends StatelessWidget {
  const SecurityTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.onContinue,
  });

  final SecurityType selectedType;
  final void Function(SecurityType type) onTypeSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title
        const Text(
          'Set Up Security',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          'Choose how you want to protect your data',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 40),
        // Security type cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _SecurityTypeCard(
                type: SecurityType.pin,
                title: '6-Digit PIN',
                description: 'Quick and easy to use',
                icon: Icons.dialpad,
                isSelected: selectedType == SecurityType.pin,
                onTap: () => onTypeSelected(SecurityType.pin),
              ),
              const SizedBox(height: 16),
              _SecurityTypeCard(
                type: SecurityType.pattern,
                title: 'Pattern Lock',
                description: 'Draw a pattern to unlock',
                icon: Icons.pattern,
                isSelected: selectedType == SecurityType.pattern,
                onTap: () => onTypeSelected(SecurityType.pattern),
              ),
              const SizedBox(height: 16),
              _SecurityTypeCard(
                type: SecurityType.password,
                title: 'Password',
                description: 'Strong password protection',
                icon: Icons.lock_outline,
                isSelected: selectedType == SecurityType.password,
                onTap: () => onTypeSelected(SecurityType.password),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Continue button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onContinue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityTypeCard extends StatefulWidget {
  const _SecurityTypeCard({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final SecurityType type;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_SecurityTypeCard> createState() => _SecurityTypeCardState();
}

class _SecurityTypeCardState extends State<_SecurityTypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Checkmark
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 16,
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
