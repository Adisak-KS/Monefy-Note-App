import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeHeader extends StatefulWidget {
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final String? userName;
  final String? userAvatarUrl;

  const HomeHeader({
    super.key,
    this.onAvatarTap,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.userName,
    this.userAvatarUrl,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _avatarScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static GreetingData getGreetingData() {
    final hours = DateTime.now().hour;
    if (hours < 12) {
      return GreetingData(
        text: 'home.greeting_morning'.tr(),
        emoji: '☀️',
      );
    } else if (hours < 17) {
      return GreetingData(
        text: 'home.greeting_afternoon'.tr(),
        emoji: '🌤️',
      );
    } else {
      return GreetingData(
        text: 'home.greeting_evening'.tr(),
        emoji: '🌙',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greetingData = getGreetingData();
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Animated Avatar
          ScaleTransition(
            scale: _avatarScaleAnimation,
            child: _AnimatedAvatar(
              onTap: () {
                HapticFeedback.lightImpact();
                if (widget.onAvatarTap != null) {
                  widget.onAvatarTap!();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              theme: theme,
              isDark: isDark,
              userName: widget.userName,
              avatarUrl: widget.userAvatarUrl,
            ),
          ),
          const SizedBox(width: 14),
          // Greeting & Date with animation
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnimatedGreeting(
                      greetingData: greetingData,
                      userName: widget.userName,
                      theme: theme,
                    ),
                    const SizedBox(height: 4),
                    _DateBadge(theme: theme),
                  ],
                ),
              ),
            ),
          ),
          // Notification Button with animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: _ActionButton(
              icon: Icons.notifications_outlined,
              badgeCount: widget.notificationCount,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onNotificationTap?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GreetingData {
  final String text;
  final String emoji;

  const GreetingData({
    required this.text,
    required this.emoji,
  });
}

class _DateBadge extends StatelessWidget {
  final ThemeData theme;

  const _DateBadge({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('EEEE, d MMM', context.locale.toString())
                .format(DateTime.now()),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedAvatar extends StatefulWidget {
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;
  final String? userName;
  final String? avatarUrl;

  const _AnimatedAvatar({
    required this.onTap,
    required this.theme,
    required this.isDark,
    this.userName,
    this.avatarUrl,
  });

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getInitials() {
    if (widget.userName == null || widget.userName!.isEmpty) {
      return '';
    }
    final names = widget.userName!.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.theme.colorScheme.primary,
                    widget.theme.colorScheme.secondary,
                    widget.theme.colorScheme.tertiary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.colorScheme.primary.withValues(
                      alpha: 0.3 + (_pulseController.value * 0.2),
                    ),
                    blurRadius: 12 + (_pulseController.value * 4),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner ring
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Avatar content
                  _buildAvatarContent(),
                  // Online indicator
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isDark
                              ? const Color(0xFF161B22)
                              : Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    // Show network image if URL is provided
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          widget.avatarUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    final initials = _getInitials();

    // Show initials if user name is provided
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Default icon
    return const Icon(
      Icons.person_rounded,
      color: Colors.white,
      size: 26,
    );
  }
}

class _AnimatedGreeting extends StatefulWidget {
  final GreetingData greetingData;
  final String? userName;
  final ThemeData theme;

  const _AnimatedGreeting({
    required this.greetingData,
    this.userName,
    required this.theme,
  });

  @override
  State<_AnimatedGreeting> createState() => _AnimatedGreetingState();
}

class _AnimatedGreetingState extends State<_AnimatedGreeting>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Play wave animation once after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _waveController.forward().then((_) {
          if (mounted) _waveController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            _buildGreetingText(),
            style: widget.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _waveController.value * 0.5,
              child: child,
            );
          },
          child: Text(
            widget.greetingData.emoji,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ],
    );
  }

  String _buildGreetingText() {
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      final firstName = widget.userName!.split(' ').first;
      return '${widget.greetingData.text}, $firstName';
    }
    return widget.greetingData.text;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
