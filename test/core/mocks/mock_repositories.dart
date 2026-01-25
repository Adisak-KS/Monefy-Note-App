import 'package:mocktail/mocktail.dart';
import 'package:monefy_note_app/core/repositories/transaction_repository.dart';
import 'package:monefy_note_app/core/repositories/category_repository.dart';
import 'package:monefy_note_app/core/repositories/wallet_repository.dart';
import 'package:monefy_note_app/core/repositories/budget_repository.dart';
import 'package:monefy_note_app/core/bloc/drawer_stats_cubit.dart';
import 'package:monefy_note_app/core/models/transaction.dart';
import 'package:monefy_note_app/core/models/category.dart';
import 'package:monefy_note_app/core/models/wallet.dart';
import 'package:monefy_note_app/core/models/budget.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/core/models/wallet_type.dart';

// Mock Repository Classes
class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockDrawerStatsCubit extends Mock implements DrawerStatsCubit {}

// Test Data Factory
class TestDataFactory {
  static const testCategoryId = 'test-category-001';
  static const testWalletId = 'test-wallet-001';

  static List<Category> get mockCategories => [
        const Category(
          id: testCategoryId,
          name: 'Food',
          type: TransactionType.expense,
          icon: 'restaurant',
          color: '#FF5722',
        ),
        const Category(
          id: 'test-category-002',
          name: 'Salary',
          type: TransactionType.income,
          icon: 'payments',
          color: '#4CAF50',
        ),
      ];

  static List<Wallet> get mockWallets => [
        const Wallet(
          id: testWalletId,
          name: 'Cash',
          type: WalletType.cash,
          balance: 1000,
          color: '#22C55E',
        ),
        const Wallet(
          id: 'test-wallet-002',
          name: 'Bank',
          type: WalletType.bank,
          balance: 5000,
          color: '#3B82F6',
        ),
      ];

  static List<Transaction> get mockTransactions => [
        Transaction(
          id: 'test-tx-001',
          type: TransactionType.expense,
          amount: 100,
          date: DateTime.now(),
          categoryId: testCategoryId,
          walletId: testWalletId,
          description: 'Test expense',
        ),
        Transaction(
          id: 'test-tx-002',
          type: TransactionType.income,
          amount: 500,
          date: DateTime.now(),
          categoryId: 'test-category-002',
          walletId: testWalletId,
          description: 'Test income',
        ),
      ];

  static List<Budget> get mockBudgets => [
        Budget(
          id: 'test-budget-001',
          categoryId: testCategoryId,
          amount: 1000,
          spent: 250,
          month: DateTime.now().month,
          year: DateTime.now().year,
        ),
      ];

  static Transaction createTransaction({
    String? id,
    TransactionType type = TransactionType.expense,
    double amount = 100,
    DateTime? date,
    String? categoryId,
    String? walletId,
    String? description,
  }) {
    return Transaction(
      id: id ?? 'test-tx-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      amount: amount,
      date: date ?? DateTime.now(),
      categoryId: categoryId ?? testCategoryId,
      walletId: walletId ?? testWalletId,
      description: description,
    );
  }
}

// Register fallback values (call this in setUpAll)
void registerFallbackValues() {
  // Use real instances as fallback values for sealed classes
  registerFallbackValue(
    Transaction(
      id: 'fallback',
      type: TransactionType.expense,
      amount: 0,
      date: DateTime(2024),
      categoryId: 'fallback',
      walletId: 'fallback',
    ),
  );
  registerFallbackValue(
    const Category(
      id: 'fallback',
      name: 'Fallback',
      type: TransactionType.expense,
    ),
  );
  registerFallbackValue(
    const Wallet(
      id: 'fallback',
      name: 'Fallback',
      type: WalletType.cash,
    ),
  );
  registerFallbackValue(
    Budget(
      id: 'fallback',
      categoryId: 'fallback',
      amount: 0,
      spent: 0,
      month: 1,
      year: 2024,
    ),
  );
  registerFallbackValue(TransactionType.expense);
  registerFallbackValue(DateTime(2024));
}
