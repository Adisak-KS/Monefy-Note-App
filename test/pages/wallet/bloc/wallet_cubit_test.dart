import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:monefy_note_app/core/models/wallet.dart';
import 'package:monefy_note_app/core/models/wallet_type.dart';
import 'package:monefy_note_app/pages/wallet/bloc/wallet_cubit.dart';
import 'package:monefy_note_app/pages/wallet/bloc/wallet_state.dart';

import '../../../core/mocks/mock_repositories.dart';

void main() {
  late WalletCubit walletCubit;
  late MockWalletRepository mockWalletRepo;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockWalletRepo = MockWalletRepository();
    walletCubit = WalletCubit(mockWalletRepo);
  });

  tearDown(() {
    walletCubit.close();
  });

  group('WalletCubit', () {
    test('initial state is WalletInitial', () {
      expect(walletCubit.state, isA<WalletInitial>());
    });

    group('loadWallets', () {
      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletLoaded] when loadWallets succeeds',
        build: () {
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => TestDataFactory.mockWallets);
          return walletCubit;
        },
        act: (cubit) => cubit.loadWallets(),
        expect: () => [
          isA<WalletLoading>(),
          isA<WalletLoaded>()
              .having((s) => s.wallets.length, 'wallets count', 2)
              .having((s) => s.totalBalance, 'total balance', 6000), // 1000 + 5000
        ],
        verify: (_) {
          verify(() => mockWalletRepo.getAll()).called(1);
        },
      );

      blocTest<WalletCubit, WalletState>(
        'emits [WalletLoading, WalletError] when loadWallets fails',
        build: () {
          when(() => mockWalletRepo.getAll())
              .thenThrow(Exception('Failed to load wallets'));
          return walletCubit;
        },
        act: (cubit) => cubit.loadWallets(),
        expect: () => [
          isA<WalletLoading>(),
          isA<WalletError>().having(
            (s) => s.message,
            'error message',
            contains('Failed to load wallets'),
          ),
        ],
      );

      blocTest<WalletCubit, WalletState>(
        'calculates totalDebt correctly for liability wallets',
        build: () {
          final walletsWithDebt = [
            ...TestDataFactory.mockWallets,
            const Wallet(
              id: 'credit-card',
              name: 'Credit Card',
              type: WalletType.creditCard,
              balance: -5000,
              includeInTotal: true,
            ),
          ];
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => walletsWithDebt);
          return walletCubit;
        },
        act: (cubit) => cubit.loadWallets(),
        expect: () => [
          isA<WalletLoading>(),
          isA<WalletLoaded>()
              .having((s) => s.totalDebt, 'total debt', 5000),
        ],
      );
    });

    group('addWallet', () {
      blocTest<WalletCubit, WalletState>(
        'adds wallet and refreshes list',
        build: () {
          when(() => mockWalletRepo.add(any())).thenAnswer((_) async {});
          final newWalletList = [
            ...TestDataFactory.mockWallets,
            const Wallet(
              id: 'new-wallet',
              name: 'New Wallet',
              type: WalletType.cash,
              balance: 100,
            ),
          ];
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => newWalletList);
          return walletCubit;
        },
        seed: () => WalletLoaded(
          wallets: TestDataFactory.mockWallets,
          totalBalance: 6000,
          totalDebt: 0,
        ),
        act: (cubit) => cubit.addWallet(
          const Wallet(
            id: 'new-wallet',
            name: 'New Wallet',
            type: WalletType.cash,
            balance: 100,
          ),
        ),
        expect: () => [
          isA<WalletLoaded>().having(
            (s) => s.wallets.length,
            'wallets count after add',
            3,
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepo.add(any())).called(1);
          verify(() => mockWalletRepo.getAll()).called(1);
        },
      );

      blocTest<WalletCubit, WalletState>(
        'does nothing when not in WalletLoaded state',
        build: () => walletCubit,
        act: (cubit) => cubit.addWallet(TestDataFactory.mockWallets.first),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockWalletRepo.add(any()));
        },
      );
    });

    group('deleteWallet', () {
      blocTest<WalletCubit, WalletState>(
        'deletes wallet and stores for undo',
        build: () {
          when(() => mockWalletRepo.delete(any())).thenAnswer((_) async {});
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => [TestDataFactory.mockWallets.last]);
          return walletCubit;
        },
        seed: () => WalletLoaded(
          wallets: TestDataFactory.mockWallets,
          totalBalance: 6000,
          totalDebt: 0,
        ),
        act: (cubit) => cubit.deleteWallet(TestDataFactory.testWalletId),
        expect: () => [
          isA<WalletLoaded>()
              .having((s) => s.recentlyDeletedWallet, 'deleted wallet', isNotNull)
              .having((s) => s.wallets.length, 'wallets count', 1),
        ],
        verify: (_) {
          verify(() => mockWalletRepo.delete(TestDataFactory.testWalletId)).called(1);
        },
      );
    });

    group('transfer', () {
      blocTest<WalletCubit, WalletState>(
        'transfers amount between wallets',
        build: () {
          when(() => mockWalletRepo.updateBalance(any(), any()))
              .thenAnswer((_) async {});
          // Return updated balances to create a different state
          final updatedWallets = [
            TestDataFactory.mockWallets.first.copyWith(balance: 900),
            TestDataFactory.mockWallets.last.copyWith(balance: 5100),
          ];
          when(() => mockWalletRepo.getAll())
              .thenAnswer((_) async => updatedWallets);
          return walletCubit;
        },
        seed: () => WalletLoaded(
          wallets: TestDataFactory.mockWallets,
          totalBalance: 6000,
          totalDebt: 0,
        ),
        act: (cubit) => cubit.transfer(
          fromWalletId: TestDataFactory.testWalletId,
          toWalletId: 'test-wallet-002',
          amount: 100,
        ),
        expect: () => [
          // State changes because wallet balances changed
          isA<WalletLoaded>().having(
            (s) => s.wallets.first.balance,
            'source wallet balance after transfer',
            900,
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepo.updateBalance(TestDataFactory.testWalletId, -100)).called(1);
          verify(() => mockWalletRepo.updateBalance('test-wallet-002', 100)).called(1);
        },
      );

      blocTest<WalletCubit, WalletState>(
        'does not transfer zero or negative amount',
        build: () => walletCubit,
        seed: () => WalletLoaded(
          wallets: TestDataFactory.mockWallets,
          totalBalance: 6000,
          totalDebt: 0,
        ),
        act: (cubit) => cubit.transfer(
          fromWalletId: TestDataFactory.testWalletId,
          toWalletId: 'test-wallet-002',
          amount: 0,
        ),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockWalletRepo.updateBalance(any(), any()));
        },
      );
    });

    group('archiveWallet', () {
      blocTest<WalletCubit, WalletState>(
        'archives wallet successfully',
        build: () {
          when(() => mockWalletRepo.update(any())).thenAnswer((_) async {});
          when(() => mockWalletRepo.getAll()).thenAnswer((_) async {
            return TestDataFactory.mockWallets.map((w) {
              if (w.id == TestDataFactory.testWalletId) {
                return w.copyWith(isArchived: true);
              }
              return w;
            }).toList();
          });
          return walletCubit;
        },
        seed: () => WalletLoaded(
          wallets: TestDataFactory.mockWallets,
          totalBalance: 6000,
          totalDebt: 0,
        ),
        act: (cubit) => cubit.archiveWallet(TestDataFactory.testWalletId),
        expect: () => [
          isA<WalletLoaded>(),
        ],
        verify: (_) {
          verify(() => mockWalletRepo.update(any())).called(1);
        },
      );
    });

    group('undoDelete', () {
      blocTest<WalletCubit, WalletState>(
        'restores deleted wallet after delete',
        build: () {
          when(() => mockWalletRepo.delete(any())).thenAnswer((_) async {});
          when(() => mockWalletRepo.add(any())).thenAnswer((_) async {});
          // First call returns wallet without deleted, second call returns all
          var callCount = 0;
          when(() => mockWalletRepo.getAll()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return [TestDataFactory.mockWallets.last];
            }
            return TestDataFactory.mockWallets;
          });
          return walletCubit;
        },
        seed: () => WalletLoaded(
          wallets: TestDataFactory.mockWallets,
          totalBalance: 6000,
          totalDebt: 0,
        ),
        act: (cubit) async {
          // First delete, then undo
          await cubit.deleteWallet(TestDataFactory.testWalletId);
          await cubit.undoDelete();
        },
        expect: () => [
          // After delete
          isA<WalletLoaded>().having(
            (s) => s.recentlyDeletedWallet,
            'has deleted wallet',
            isNotNull,
          ),
          // After undo
          isA<WalletLoaded>().having(
            (s) => s.recentlyDeletedWallet,
            'deleted wallet cleared',
            isNull,
          ),
        ],
        verify: (_) {
          verify(() => mockWalletRepo.delete(TestDataFactory.testWalletId)).called(1);
          verify(() => mockWalletRepo.add(any())).called(1);
        },
      );
    });
  });
}
