/// Supported currencies with their symbols and display information
enum Currency {
  thb('THB', '฿', 'Thai Baht', '🇹🇭'),
  usd('USD', '\$', 'US Dollar', '🇺🇸'),
  eur('EUR', '€', 'Euro', '🇪🇺'),
  gbp('GBP', '£', 'British Pound', '🇬🇧'),
  jpy('JPY', '¥', 'Japanese Yen', '🇯🇵'),
  cny('CNY', '¥', 'Chinese Yuan', '🇨🇳'),
  krw('KRW', '₩', 'Korean Won', '🇰🇷'),
  inr('INR', '₹', 'Indian Rupee', '🇮🇳'),
  sgd('SGD', 'S\$', 'Singapore Dollar', '🇸🇬'),
  myr('MYR', 'RM', 'Malaysian Ringgit', '🇲🇾'),
  idr('IDR', 'Rp', 'Indonesian Rupiah', '🇮🇩'),
  vnd('VND', '₫', 'Vietnamese Dong', '🇻🇳'),
  php('PHP', '₱', 'Philippine Peso', '🇵🇭'),
  aud('AUD', 'A\$', 'Australian Dollar', '🇦🇺'),
  cad('CAD', 'C\$', 'Canadian Dollar', '🇨🇦'),
  chf('CHF', 'Fr', 'Swiss Franc', '🇨🇭'),
  hkd('HKD', 'HK\$', 'Hong Kong Dollar', '🇭🇰'),
  twd('TWD', 'NT\$', 'Taiwan Dollar', '🇹🇼'),
  nzd('NZD', 'NZ\$', 'New Zealand Dollar', '🇳🇿'),
  btc('BTC', '₿', 'Bitcoin', '🪙'),
  eth('ETH', 'Ξ', 'Ethereum', '🪙');

  const Currency(this.code, this.symbol, this.name, this.flag);

  final String code;
  final String symbol;
  final String name;
  final String flag;

  /// Get currency by code
  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code.toUpperCase() == code.toUpperCase(),
      orElse: () => Currency.thb,
    );
  }

  /// Format amount with currency symbol
  String format(double amount, {int decimalDigits = 2}) {
    // Special handling for currencies that typically don't use decimals
    final decimals = (this == Currency.jpy || this == Currency.krw || this == Currency.vnd)
        ? 0
        : decimalDigits;

    final formatted = amount.toStringAsFixed(decimals);
    return '$symbol$formatted';
  }

  /// Get display label with flag and code
  String get displayLabel => '$flag $code';

  /// Get full display name
  String get fullName => '$flag $code - $name';
}
