import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:monefy_note_app/pages/splash/bloc/splash_state.dart';
import 'package:vibration/vibration.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({this.enableSound = true}) : super(SplashInitial());

  final bool enableSound;
  AudioPlayer? _audioPlayer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSkipped = false;
  bool _canSkip = false;
  bool _isOffline = false;
  double _currentProgress = 0.0;

  bool get canSkip => _canSkip;

  Future<void> initialize() async {
    _isSkipped = false;
    _canSkip = false;
    _currentProgress = 0.0;

    // Check connectivity first
    _isOffline = await _checkConnectivity();
    emit(SplashLoading(progress: 0.0, isOffline: _isOffline));

    // Start real-time connectivity monitoring
    _startConnectivityMonitoring();

    try {
      // Enable skip after 1 second
      Future.delayed(const Duration(seconds: 1), () {
        _canSkip = true;
      });

      // Step 1: Load preferences (0% -> 30%)
      await _updateProgress(0.0, 0.3);
      if (_isSkipped) return;
      await _loadPreferences();

      // Step 2: Check first launch (30% -> 60%)
      await _updateProgress(0.3, 0.6);
      if (_isSkipped) return;
      await _checkFirstLaunch();

      // Step 3: Final loading (60% -> 100%)
      await _updateProgress(0.6, 1.0);
      if (_isSkipped) return;

      // Haptic feedback & sound when done
      await _triggerHapticFeedback();
      await _playStartupSound();

      emit(SplashLoaded());
    } catch (error) {
      emit(SplashError(error.toString()));
    }
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (result) {
        final wasOffline = _isOffline;
        _isOffline = result.contains(ConnectivityResult.none);

        // Only emit if state changed and still loading
        if (wasOffline != _isOffline && state is SplashLoading) {
          emit(SplashLoading(progress: _currentProgress, isOffline: _isOffline));
        }
      },
    );
  }

  /// Skip splash and go to home immediately
  void skip() {
    if (_canSkip) {
      _isSkipped = true;
      _triggerHapticFeedback();
      emit(SplashLoaded());
    }
  }

  /// Animate progress from start to end (smooth animation)
  Future<void> _updateProgress(double start, double end) async {
    const steps = 30; // More steps = smoother animation
    const totalDuration = 800; // Total duration in ms
    final increment = (end - start) / steps;
    const stepDuration = Duration(milliseconds: totalDuration ~/ steps);

    for (int i = 0; i <= steps; i++) {
      if (_isSkipped) return;
      _currentProgress = (start + (increment * i)).clamp(0.0, 1.0);
      emit(SplashLoading(progress: _currentProgress, isOffline: _isOffline));
      await Future.delayed(stepDuration);
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadPreferences() async {
    // TODO: Load from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _checkFirstLaunch() async {
    // TODO: Check if first time launch
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _triggerHapticFeedback() async {
    try {
      // Use platform-specific haptic feedback
      if (kIsWeb) return;

      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        await Vibration.vibrate(duration: 50, amplitude: 128);
      } else {
        // Fallback to system haptic
        await HapticFeedback.mediumImpact();
      }
    } catch (_) {
      // Ignore haptic errors
    }
  }

  Future<void> _playStartupSound() async {
    if (!enableSound || kIsWeb) return;

    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setAsset('assets/sounds/startup.mp3');
      await _audioPlayer!.setVolume(0.5);
      await _audioPlayer!.play();
    } catch (_) {
      // Ignore sound errors - file might not exist
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _audioPlayer?.dispose();
    return super.close();
  }
}
