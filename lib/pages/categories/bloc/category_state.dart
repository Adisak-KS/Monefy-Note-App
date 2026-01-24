import 'package:equatable/equatable.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction_type.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  final TransactionType selectedTab;

  const CategoryLoaded({
    required this.expenseCategories,
    required this.incomeCategories,
    this.selectedTab = TransactionType.expense,
  });

  List<Category> get currentCategories =>
      selectedTab == TransactionType.expense ? expenseCategories : incomeCategories;

  @override
  List<Object?> get props => [expenseCategories, incomeCategories, selectedTab];

  CategoryLoaded copyWith({
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
    TransactionType? selectedTab,
  }) {
    return CategoryLoaded(
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
