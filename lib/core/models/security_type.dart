enum SecurityType {
  pin,      // 6-digit PIN (default)
  pattern,  // 3x3 pattern (min 4 dots)
  password, // min 6 characters
}

extension SecurityTypeExtension on SecurityType {
  String get name {
    switch (this) {
      case SecurityType.pin:
        return 'pin';
      case SecurityType.pattern:
        return 'pattern';
      case SecurityType.password:
        return 'password';
    }
  }

  static SecurityType fromString(String value) {
    switch (value) {
      case 'pin':
        return SecurityType.pin;
      case 'pattern':
        return SecurityType.pattern;
      case 'password':
        return SecurityType.password;
      default:
        return SecurityType.pin;
    }
  }
}
