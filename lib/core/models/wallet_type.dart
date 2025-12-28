import 'package:flutter/material.dart';

enum WalletType {
  cash,
  bank,
  creditCard,
  eWallet,
  investment,
  debt,
  // New types
  crypto,
  savings,
  loan,
  insurance,
  gold,
}

extension WalletTypeExtension on WalletType {
  String get value {
    switch (this) {
      case WalletType.cash:
        return 'cash';
      case WalletType.bank:
        return 'bank';
      case WalletType.creditCard:
        return 'credit_card';
      case WalletType.eWallet:
        return 'e_wallet';
      case WalletType.investment:
        return 'investment';
      case WalletType.debt:
        return 'debt';
      case WalletType.crypto:
        return 'crypto';
      case WalletType.savings:
        return 'savings';
      case WalletType.loan:
        return 'loan';
      case WalletType.insurance:
        return 'insurance';
      case WalletType.gold:
        return 'gold';
    }
  }

  IconData get icon {
    switch (this) {
      case WalletType.cash:
        return Icons.payments_rounded;
      case WalletType.bank:
        return Icons.account_balance_rounded;
      case WalletType.creditCard:
        return Icons.credit_card_rounded;
      case WalletType.eWallet:
        return Icons.phone_android_rounded;
      case WalletType.investment:
        return Icons.trending_up_rounded;
      case WalletType.debt:
        return Icons.money_off_rounded;
      case WalletType.crypto:
        return Icons.currency_bitcoin_rounded;
      case WalletType.savings:
        return Icons.savings_rounded;
      case WalletType.loan:
        return Icons.real_estate_agent_rounded;
      case WalletType.insurance:
        return Icons.health_and_safety_rounded;
      case WalletType.gold:
        return Icons.diamond_rounded;
    }
  }

  Color get color {
    switch (this) {
      case WalletType.cash:
        return const Color(0xFF22C55E);
      case WalletType.bank:
        return const Color(0xFF3B82F6);
      case WalletType.creditCard:
        return const Color(0xFFF59E0B);
      case WalletType.eWallet:
        return const Color(0xFF8B5CF6);
      case WalletType.investment:
        return const Color(0xFF06B6D4);
      case WalletType.debt:
        return const Color(0xFFEF4444);
      case WalletType.crypto:
        return const Color(0xFFF97316);
      case WalletType.savings:
        return const Color(0xFF10B981);
      case WalletType.loan:
        return const Color(0xFFEC4899);
      case WalletType.insurance:
        return const Color(0xFF6366F1);
      case WalletType.gold:
        return const Color(0xFFEAB308);
    }
  }

  /// Whether this wallet type is considered a liability (negative balance)
  bool get isLiability {
    switch (this) {
      case WalletType.debt:
      case WalletType.creditCard:
      case WalletType.loan:
        return true;
      default:
        return false;
    }
  }

  static WalletType fromString(String value) {
    switch (value) {
      case 'cash':
        return WalletType.cash;
      case 'bank':
        return WalletType.bank;
      case 'credit_card':
        return WalletType.creditCard;
      case 'e_wallet':
        return WalletType.eWallet;
      case 'investment':
        return WalletType.investment;
      case 'debt':
        return WalletType.debt;
      case 'crypto':
        return WalletType.crypto;
      case 'savings':
        return WalletType.savings;
      case 'loan':
        return WalletType.loan;
      case 'insurance':
        return WalletType.insurance;
      case 'gold':
        return WalletType.gold;
      default:
        return WalletType.cash;
    }
  }
}
