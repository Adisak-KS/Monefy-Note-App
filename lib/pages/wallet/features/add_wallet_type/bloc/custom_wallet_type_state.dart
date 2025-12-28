import 'package:equatable/equatable.dart';
import '../../../../../core/models/custom_wallet_type.dart';

abstract class CustomWalletTypeState extends Equatable {
  const CustomWalletTypeState();

  @override
  List<Object?> get props => [];
}

class CustomWalletTypeInitial extends CustomWalletTypeState {
  const CustomWalletTypeInitial();
}

class CustomWalletTypeLoading extends CustomWalletTypeState {
  const CustomWalletTypeLoading();
}

class CustomWalletTypeLoaded extends CustomWalletTypeState {
  final List<CustomWalletType> types;

  const CustomWalletTypeLoaded({required this.types});

  @override
  List<Object?> get props => [types];
}

class CustomWalletTypeError extends CustomWalletTypeState {
  final String message;

  const CustomWalletTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
