import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:monefy_note_app/core/cubit/network_cubit.dart';
import 'package:monefy_note_app/core/services/network_service.dart';

class NetworkStatusBanner extends StatefulWidget {
  const NetworkStatusBanner({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _pulseController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _wasOffline = false;
  bool _showOnlineBanner = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.6),
      ),
    );

    // Check initial status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentStatus = context.read<NetworkCubit>().state;
      if (currentStatus == NetworkStatus.offline) {
        _wasOffline = true;
        _slideController.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStatusChanged(NetworkStatus status) {
    if (status == NetworkStatus.offline) {
      _wasOffline = true;
      _showOnlineBanner = false;
      _slideController.forward();
      _pulseController.repeat(reverse: true);
      HapticFeedback.heavyImpact();
    } else if (status == NetworkStatus.online && _wasOffline) {
      setState(() => _showOnlineBanner = true);
      _pulseController.stop();
      _pulseController.reset();
      HapticFeedback.mediumImpact();

      // Show online banner briefly then hide
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _slideController.reverse();
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() {
                _showOnlineBanner = false;
                _wasOffline = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkStatus>(
      listener: (context, status) => _onStatusChanged(status),
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: BlocBuilder<NetworkCubit, NetworkStatus>(
                  builder: (context, status) {
                    final isOffline = status == NetworkStatus.offline;
                    final showBanner = isOffline || _showOnlineBanner;

                    if (!showBanner && !_slideController.isAnimating) {
                      return const SizedBox.shrink();
                    }

                    return SafeArea(
                      bottom: false,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isOffline
                                ? const Color(0xFFE53935)
                                : const Color(0xFF43A047),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: (isOffline
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFF43A047))
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Animated icon
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: isOffline
                                        ? 1.0 + (_pulseController.value * 0.15)
                                        : 1.0,
                                    child: Icon(
                                      isOffline
                                          ? Icons.wifi_off_rounded
                                          : Icons.wifi_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              // Text
                              Text(
                                isOffline
                                    ? 'network.offline'.tr()
                                    : 'network.online'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              // Status indicator for offline
                              if (isOffline) ...[
                                const SizedBox(width: 8),
                                _buildPulsingDot(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(
                  alpha: 0.6 * _pulseController.value,
                ),
                blurRadius: 6 * _pulseController.value,
                spreadRadius: 1 * _pulseController.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
