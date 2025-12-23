import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {
  final double progress;
  final bool isOffline;

  const SplashLoading({
    this.progress = 0.0,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [progress, isOffline];

  SplashLoading copyWith({
    double? progress,
    bool? isOffline,
  }) {
    return SplashLoading(
      progress: progress ?? this.progress,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class SplashLoaded extends SplashState {
  final String destination;

  const SplashLoaded({this.destination = '/home'});

  @override
  List<Object?> get props => [destination];
}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
