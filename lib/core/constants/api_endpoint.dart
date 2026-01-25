class ApiEndpoint {
  // Base Configuration
  static const String baseUrl = 'http://localhost:3001/api/v1';
  static const Duration connectTimeOut = Duration(seconds: 30);
  static const Duration receiveTime = Duration(seconds: 30);

  // Auth endpoints
  static const String signUp = '/auth/signup';
  static const String signIn = '/auth/signin';
  static const String refresh = '/auth/refresh';
  static const String signOut = '/auth/signout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Wallet endpoints
  static const String wallets = '/wallets';
  static String wallet(String id) => '/wallets/$id';

  // Transaction endpoints
  static const String transactions = '/transactions';
  static const String transactionSummary = '/transactions/summary';
  static String transaction(String id) => '/transactions/$id';

  // Category endpoints
  static const String categories = '/categories';
  static String category(String id) => '/categories/$id';

  //  Budget endpoints
  static const String budgets = '/budgets';
  static String budget(String id) => '/budgets/$id';
  static String budgetsStatus(String id) => '/budgets/$id/status';
  static String budgetRollover(String id) => '/budgets/$id/rollover';

  // Transfer endpoints
  static const String transfers = '/transfers';
  static String transfer(String id) => '/transfers/$id';
}
