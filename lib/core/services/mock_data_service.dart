import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/wallet.dart';
import '../models/wallet_type.dart';

class MockDataService {
  static const _uuid = Uuid();

  // Fixed IDs for reference
  static const walletCashId = 'wallet-cash-001';
  static const walletBankId = 'wallet-bank-001';
  static const walletSavingsId = 'wallet-savings-001';
  static const walletCreditId = 'wallet-credit-001';
  static const walletEwalletId = 'wallet-ewallet-001';
  static const walletCryptoId = 'wallet-crypto-001';
  static const walletInvestId = 'wallet-invest-001';
  static const walletGoldId = 'wallet-gold-001';
  static const walletLoanId = 'wallet-loan-001';
  static const walletArchivedId = 'wallet-archived-001';

  // Fixed Category IDs
  static const catFoodId = 'cat-food-001';
  static const catTransportId = 'cat-transport-001';
  static const catShoppingId = 'cat-shopping-001';
  static const catEntertainmentId = 'cat-entertainment-001';
  static const catBillsId = 'cat-bills-001';
  static const catHealthId = 'cat-health-001';
  static const catSalaryId = 'cat-salary-001';
  static const catFreelanceId = 'cat-freelance-001';
  static const catInvestmentId = 'cat-investment-001';
  static const catGiftId = 'cat-gift-001';

  // Default Categories
  static final List<Category> defaultCategories = [
    // Expense
    Category(id: catFoodId, name: 'อาหาร', type: TransactionType.expense, icon: 'restaurant', color: '#FF5722'),
    Category(id: catTransportId, name: 'เดินทาง', type: TransactionType.expense, icon: 'directions_car', color: '#2196F3'),
    Category(id: catShoppingId, name: 'ช้อปปิ้ง', type: TransactionType.expense, icon: 'shopping_bag', color: '#E91E63'),
    Category(id: catEntertainmentId, name: 'บันเทิง', type: TransactionType.expense, icon: 'movie', color: '#9C27B0'),
    Category(id: catBillsId, name: 'ค่าใช้จ่าย', type: TransactionType.expense, icon: 'receipt', color: '#607D8B'),
    Category(id: catHealthId, name: 'สุขภาพ', type: TransactionType.expense, icon: 'medical_services', color: '#4CAF50'),
    // Income
    Category(id: catSalaryId, name: 'เงินเดือน', type: TransactionType.income, icon: 'payments', color: '#4CAF50'),
    Category(id: catFreelanceId, name: 'รายได้เสริม', type: TransactionType.income, icon: 'work', color: '#FF9800'),
    Category(id: catInvestmentId, name: 'ลงทุน', type: TransactionType.income, icon: 'trending_up', color: '#03A9F4'),
    Category(id: catGiftId, name: 'ของขวัญ', type: TransactionType.income, icon: 'card_giftcard', color: '#F44336'),
  ];

  // Default Wallets
  static final List<Wallet> defaultWallets = [
    // Cash
    const Wallet(
      id: walletCashId,
      name: 'เงินสด',
      type: WalletType.cash,
      balance: 5250,
      color: '#22C55E',
    ),
    // Bank Account
    const Wallet(
      id: walletBankId,
      name: 'กสิกรไทย',
      type: WalletType.bank,
      balance: 45780.50,
      color: '#3B82F6',
    ),
    // Savings Account
    const Wallet(
      id: walletSavingsId,
      name: 'บัญชีออมทรัพย์',
      type: WalletType.savings,
      balance: 150000,
      color: '#10B981',
    ),
    // Credit Card
    const Wallet(
      id: walletCreditId,
      name: 'บัตรเครดิต SCB',
      type: WalletType.creditCard,
      balance: -12500,
      color: '#F59E0B',
    ),
    // E-Wallet
    const Wallet(
      id: walletEwalletId,
      name: 'TrueMoney',
      type: WalletType.eWallet,
      balance: 3200,
      color: '#8B5CF6',
    ),
    // Cryptocurrency
    const Wallet(
      id: walletCryptoId,
      name: 'Bitkub',
      type: WalletType.crypto,
      balance: 25000,
      color: '#F97316',
      includeInTotal: false,
    ),
    // Investment
    const Wallet(
      id: walletInvestId,
      name: 'กองทุน LTF',
      type: WalletType.investment,
      balance: 80000,
      color: '#06B6D4',
    ),
    // Gold
    const Wallet(
      id: walletGoldId,
      name: 'ทองคำ 1 บาท',
      type: WalletType.gold,
      balance: 42500,
      color: '#EAB308',
      includeInTotal: false,
    ),
    // Loan (Liability)
    const Wallet(
      id: walletLoanId,
      name: 'สินเชื่อรถยนต์',
      type: WalletType.loan,
      balance: -250000,
      color: '#EC4899',
    ),
    // Archived Wallet
    const Wallet(
      id: walletArchivedId,
      name: 'บัญชีเก่า',
      type: WalletType.bank,
      balance: 500,
      color: '#6B7280',
      isArchived: true,
    ),
  ];

  // Sample Transactions
  static List<Transaction> get defaultTransactions {
    final now = DateTime.now();
    return [
      // Today's transactions
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 150,
        date: now,
        categoryId: catFoodId,
        walletId: walletCashId,
        description: 'ข้าวกลางวัน',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 85,
        date: now,
        categoryId: catFoodId,
        walletId: walletEwalletId,
        description: 'กาแฟ Starbucks',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 40,
        date: now,
        categoryId: catTransportId,
        walletId: walletCashId,
        description: 'Grab',
      ),
      // Yesterday's transactions
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 350,
        date: now.subtract(const Duration(days: 1)),
        categoryId: catFoodId,
        walletId: walletBankId,
        description: 'อาหารเย็นกับเพื่อน',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 1200,
        date: now.subtract(const Duration(days: 1)),
        categoryId: catShoppingId,
        walletId: walletCreditId,
        description: 'เสื้อผ้า UNIQLO',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 200,
        date: now.subtract(const Duration(days: 1)),
        categoryId: catEntertainmentId,
        walletId: walletEwalletId,
        description: 'ดูหนัง',
      ),
      // 2 days ago
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 1500,
        date: now.subtract(const Duration(days: 2)),
        categoryId: catBillsId,
        walletId: walletBankId,
        description: 'ค่าน้ำค่าไฟ',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 599,
        date: now.subtract(const Duration(days: 2)),
        categoryId: catBillsId,
        walletId: walletCreditId,
        description: 'Netflix',
      ),
      // 3 days ago - Salary day
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 45000,
        date: now.subtract(const Duration(days: 3)),
        categoryId: catSalaryId,
        walletId: walletBankId,
        description: 'เงินเดือน ธันวาคม',
      ),
      // 5 days ago
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 500,
        date: now.subtract(const Duration(days: 5)),
        categoryId: catHealthId,
        walletId: walletCashId,
        description: 'ยาสามัญ',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 3500,
        date: now.subtract(const Duration(days: 5)),
        categoryId: catFreelanceId,
        walletId: walletEwalletId,
        description: 'งาน Freelance',
      ),
      // 7 days ago
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 2500,
        date: now.subtract(const Duration(days: 7)),
        categoryId: catShoppingId,
        walletId: walletCreditId,
        description: 'หูฟัง Bluetooth',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 180,
        date: now.subtract(const Duration(days: 7)),
        categoryId: catTransportId,
        walletId: walletBankId,
        description: 'น้ำมันรถ',
      ),
      // 10 days ago
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 1000,
        date: now.subtract(const Duration(days: 10)),
        categoryId: catGiftId,
        walletId: walletCashId,
        description: 'ของขวัญวันเกิด',
      ),
      // 14 days ago
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.expense,
        amount: 8500,
        date: now.subtract(const Duration(days: 14)),
        categoryId: catBillsId,
        walletId: walletBankId,
        description: 'ค่าเช่าห้อง',
      ),
      Transaction(
        id: _uuid.v4(),
        type: TransactionType.income,
        amount: 2500,
        date: now.subtract(const Duration(days: 14)),
        categoryId: catInvestmentId,
        walletId: walletInvestId,
        description: 'ปันผลกองทุน',
      ),
    ];
  }
}
