import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../models/wallet.dart';
import '../models/wallet_type.dart';

class MockDataService {
  static const _uuid = Uuid();

  // Default Categories
  static final List<Category> defaultCategories = [
    // Expense
    Category(id: _uuid.v4(), name: 'อาหาร', type: TransactionType.expense, icon: 'restaurant', color: '#FF5722'),
    Category(id: _uuid.v4(), name: 'เดินทาง', type: TransactionType.expense, icon: 'directions_car', color: '#2196F3'),
    Category(id: _uuid.v4(), name: 'ช้อปปิ้ง', type: TransactionType.expense, icon: 'shopping_bag', color: '#E91E63'),
    Category(id: _uuid.v4(), name: 'บันเทิง', type: TransactionType.expense, icon: 'movie', color: '#9C27B0'),
    Category(id: _uuid.v4(), name: 'ค่าใช้จ่าย', type: TransactionType.expense, icon: 'receipt', color: '#607D8B'),
    Category(id: _uuid.v4(), name: 'สุขภาพ', type: TransactionType.expense, icon: 'medical_services', color: '#4CAF50'),
    // Income
    Category(id: _uuid.v4(), name: 'เงินเดือน', type: TransactionType.income, icon: 'payments', color: '#4CAF50'),
    Category(id: _uuid.v4(), name: 'รายได้เสริม', type: TransactionType.income, icon: 'work', color: '#FF9800'),
    Category(id: _uuid.v4(), name: 'ลงทุน', type: TransactionType.income, icon: 'trending_up', color: '#03A9F4'),
    Category(id: _uuid.v4(), name: 'ของขวัญ', type: TransactionType.income, icon: 'card_giftcard', color: '#F44336'),
  ];

  // Default Wallets
  static final List<Wallet> defaultWallets = [
    Wallet(id: _uuid.v4(), name: 'เงินสด', type: WalletType.cash, balance: 5000, icon: 'wallet', color: '#4CAF50'),
    Wallet(
      id: _uuid.v4(),
      name: 'ธนาคาร',
      type: WalletType.bank,
      balance: 25000,
      icon: 'account_balance',
      color: '#2196F3',
    ),
  ];
}
