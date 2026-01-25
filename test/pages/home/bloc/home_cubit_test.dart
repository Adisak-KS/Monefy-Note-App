import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monefy_note_app/core/models/transaction_type.dart';
import 'package:monefy_note_app/pages/home/bloc/home_cubit.dart';
import 'package:monefy_note_app/pages/home/bloc/home_state.dart';

import '../../../core/mocks/mock_repositories.dart';

void main() {
  late HomeCubit homeCubit;
  late MockTransactionRepository mockTransactionRepo;
  late MockCategoryRepository mockCategoryRepo;
  late MockWalletRepository mockWalletRepo;
  late MockDrawerStatsCubit mockDrawerStatsCubit;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockTransactionRepo = MockTransactionRepository();
    mockCategoryRepo = MockCategoryRepository();
    mockWalletRepo = MockWalletRepository();
    mockDrawerStatsCubit = MockDrawerStatsCubit();

    // Default mock behavior
    when(() => mockDrawerStatsCubit.updateStats(
          totalIncome: any(named: 'totalIncome'),
          totalExpense: any(named: 'totalExpense'),
          transactionCount: any(named: 'transactionCount'),
        )).thenReturn(null);

    homeCubit = HomeCubit(
      mockTransactionRepo,
      mockCategoryRepo,
      mockWalletRepo,
      mockDrawerStatsCubit,
    );
  });

  tearDown(() {
    homeCubit.close();
  });

  group('HomeCubit', () {
    test('initial state is HomeInitial', () {
      expect(homeCubit.state, isA<HomeInitial>());
    });

    group('loadData', () {
      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeLoaded] when loadData succeeds',
        build: () {
          when(() => mockTransactionRepo.getByDateRange(any(), any()))
              .thenAnswer((_) async => TestDataFactory.mockTransactions);
          when(() => mockCategoryRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockCategories);
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return homeCubit;
        },
        act: (cubit) => cubit.loadData(),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeLoaded>()
              .having((s) => s.todayTransactions.length, 'transactions count', 2)
              .having((s) => s.totalIncome, 'total income', 500)
              .having((s) => s.totalExpense, 'total expense', 100),
        ],
        verify: (_) {
          verify(() => mockTransactionRepo.getByDateRange(any(), any())).called(1);
          verify(() => mockCategoryRepo.getAll()).called(1);
          verify(() => mockWalletRepo.getAll()).called(1);
          verify(() => mockDrawerStatsCubit.updateStats(
                totalIncome: 500,
                totalExpense: 100,
                transactionCount: 2,
              )).called(1);
        },
      );

      blocTest<HomeCubit, HomeState>(
        'emits [HomeLoading, HomeError] when loadData fails',
        build: () {
          when(() => mockTransactionRepo.getByDateRange(any(), any()))
              .thenThrow(Exception('Failed to load'));
          when(() => mockCategoryRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockCategories);
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return homeCubit;
        },
        act: (cubit) => cubit.loadData(),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeError>().having(
            (s) => s.message,
            'error message',
            contains('Failed to load'),
          ),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'calculates totals correctly from transactions',
        build: () {
          final transactions = [
            TestDataFactory.createTransaction(
              type: TransactionType.income,
              amount: 1000,
            ),
            TestDataFactory.createTransaction(
              type: TransactionType.income,
              amount: 500,
            ),
            TestDataFactory.createTransaction(
              type: TransactionType.expense,
              amount: 200,
            ),
            TestDataFactory.createTransaction(
              type: TransactionType.expense,
              amount: 300,
            ),
          ];
          when(() => mockTransactionRepo.getByDateRange(any(), any()))
              .thenAnswer((_) async => transactions);
          when(() => mockCategoryRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockCategories);
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return homeCubit;
        },
        act: (cubit) => cubit.loadData(),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeLoaded>()
              .having((s) => s.totalIncome, 'total income', 1500)
              .having((s) => s.totalExpense, 'total expense', 500)
              .having((s) => s.balance, 'balance', 1000),
        ],
      );
    });

    group('addTransaction', () {
      blocTest<HomeCubit, HomeState>(
        'adds transaction and reloads data',
        build: () {
          when(() => mockTransactionRepo.add(any())).thenAnswer((_) async {});
          when(() => mockTransactionRepo.getByDateRange(any(), any()))
              .thenAnswer((_) async => TestDataFactory.mockTransactions);
          when(() => mockCategoryRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockCategories);
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return homeCubit;
        },
        act: (cubit) => cubit.addTransaction(
          type: TransactionType.expense,
          amount: 100,
          categoryId: TestDataFactory.testCategoryId,
          walletId: TestDataFactory.testWalletId,
          description: 'Test transaction',
        ),
        expect: () => [
          isA<HomeLoading>(),
          isA<HomeLoaded>(),
        ],
        verify: (_) {
          verify(() => mockTransactionRepo.add(any())).called(1);
        },
      );
    });

    group('deleteTransaction', () {
      blocTest<HomeCubit, HomeState>(
        'deletes transaction and stores for undo',
        build: () {
          when(() => mockTransactionRepo.getById(any()))
              .thenAnswer((_) async => TestDataFactory.mockTransactions.first);
          when(() => mockTransactionRepo.delete(any())).thenAnswer((_) async {});
          when(() => mockTransactionRepo.getByDateRange(any(), any()))
              .thenAnswer((_) async => TestDataFactory.mockTransactions);
          when(() => mockCategoryRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockCategories);
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return homeCubit;
        },
        seed: () => HomeLoaded(
          todayTransactions: TestDataFactory.mockTransactions,
          categories: TestDataFactory.mockCategories,
          wallets: TestDataFactory.mockWallets,
          totalIncome: 500,
          totalExpense: 100,
        ),
        act: (cubit) => cubit.deleteTransaction('test-tx-001'),
        expect: () => [
          isA<HomeLoaded>().having(
            (s) => s.recentlyDeletedTransaction,
            'deleted transaction',
            isNotNull,
          ),
        ],
        verify: (_) {
          verify(() => mockTransactionRepo.delete('test-tx-001')).called(1);
        },
      );
    });

    group('search', () {
      blocTest<HomeCubit, HomeState>(
        'toggleSearch enables search mode',
        build: () => homeCubit,
        seed: () => HomeLoaded(
          todayTransactions: TestDataFactory.mockTransactions,
          categories: TestDataFactory.mockCategories,
          wallets: TestDataFactory.mockWallets,
          totalIncome: 500,
          totalExpense: 100,
        ),
        act: (cubit) => cubit.toggleSearch(),
        expect: () => [
          isA<HomeLoaded>().having((s) => s.isSearching, 'isSearching', true),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'search updates searchQuery',
        build: () => homeCubit,
        seed: () => HomeLoaded(
          todayTransactions: TestDataFactory.mockTransactions,
          categories: TestDataFactory.mockCategories,
          wallets: TestDataFactory.mockWallets,
          totalIncome: 500,
          totalExpense: 100,
          isSearching: true,
        ),
        act: (cubit) => cubit.search('food'),
        expect: () => [
          isA<HomeLoaded>().having((s) => s.searchQuery, 'searchQuery', 'food'),
        ],
      );

      blocTest<HomeCubit, HomeState>(
        'clearSearch clears query and disables search mode',
        build: () => homeCubit,
        seed: () => HomeLoaded(
          todayTransactions: TestDataFactory.mockTransactions,
          categories: TestDataFactory.mockCategories,
          wallets: TestDataFactory.mockWallets,
          totalIncome: 500,
          totalExpense: 100,
          isSearching: true,
          searchQuery: 'food',
        ),
        act: (cubit) => cubit.clearSearch(),
        expect: () => [
          isA<HomeLoaded>()
              .having((s) => s.searchQuery, 'searchQuery', '')
              .having((s) => s.isSearching, 'isSearching', false),
        ],
      );
    });

    group('undoDelete', () {
      blocTest<HomeCubit, HomeState>(
        'restores deleted transaction after deleteTransaction',
        build: () {
          final deletedTransaction = TestDataFactory.mockTransactions.first;
          when(() => mockTransactionRepo.getById('test-tx-001'))
              .thenAnswer((_) async => deletedTransaction);
          when(() => mockTransactionRepo.delete(any())).thenAnswer((_) async {});
          when(() => mockTransactionRepo.add(any())).thenAnswer((_) async {});
          when(() => mockTransactionRepo.getByDateRange(any(), any()))
              .thenAnswer((_) async => TestDataFactory.mockTransactions);
          when(() => mockCategoryRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockCategories);
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return homeCubit;
        },
        seed: () => HomeLoaded(
          todayTransactions: TestDataFactory.mockTransactions,
          categories: TestDataFactory.mockCategories,
          wallets: TestDataFactory.mockWallets,
          totalIncome: 500,
          totalExpense: 100,
        ),
        act: (cubit) async {
          // First delete, then undo
          await cubit.deleteTransaction('test-tx-001');
          await cubit.undoDelete();
        },
        expect: () => [
          // After delete
          isA<HomeLoaded>().having(
            (s) => s.recentlyDeletedTransaction,
            'has deleted transaction',
            isNotNull,
          ),
          // After undo - loading
          isA<HomeLoading>(),
          // After undo - loaded
          isA<HomeLoaded>(),
        ],
        verify: (_) {
          verify(() => mockTransactionRepo.delete('test-tx-001')).called(1);
          verify(() => mockTransactionRepo.add(any())).called(1);
        },
      );
    });
  });
}
