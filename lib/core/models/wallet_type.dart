enum WalletType { cash, bank, creditCard, eWallet, debt }

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
      case WalletType.debt:
        return 'debt';
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
      case 'debt':
        return WalletType.debt;
      default:
        return WalletType.cash;
    }
  }
}
