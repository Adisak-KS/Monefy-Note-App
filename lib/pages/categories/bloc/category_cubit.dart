import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/repositories/category_repository.dart';
import 'category_state.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit(this._categoryRepository) : super(const CategoryInitial());

  Future<void> loadCategories() async {
    emit(const CategoryLoading());

    try {
      final allCategories = await _categoryRepository.getAll();

      final expenseCategories = allCategories
          .where((c) => c.type == TransactionType.expense)
          .toList();
      final incomeCategories = allCategories
          .where((c) => c.type == TransactionType.income)
          .toList();

      emit(CategoryLoaded(
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
      ));
    } catch (error) {
      emit(CategoryError(error.toString()));
    }
  }

  void switchTab(TransactionType type) {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      emit(currentState.copyWith(selectedTab: type));
    }
  }

  Future<void> addCategory({
    required String name,
    required TransactionType type,
    String? icon,
    String? color,
  }) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    final newCategory = Category(
      id: '',
      name: name,
      type: type,
      icon: icon,
      color: color,
    );

    // Optimistic: add to the appropriate list immediately
    final optimisticExpense = type == TransactionType.expense
        ? [...currentState.expenseCategories, newCategory]
        : currentState.expenseCategories;
    final optimisticIncome = type == TransactionType.income
        ? [...currentState.incomeCategories, newCategory]
        : currentState.incomeCategories;

    emit(currentState.copyWith(
      expenseCategories: optimisticExpense,
      incomeCategories: optimisticIncome,
    ));

    try {
      await _categoryRepository.add(newCategory);
      await loadCategories();
    } catch (error) {
      emit(currentState);
    }
  }

  Future<void> updateCategory(Category category) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    // Optimistic: replace in lists immediately
    final optimisticExpense = currentState.expenseCategories
        .map((c) => c.id == category.id ? category : c)
        .toList();
    final optimisticIncome = currentState.incomeCategories
        .map((c) => c.id == category.id ? category : c)
        .toList();

    emit(currentState.copyWith(
      expenseCategories: optimisticExpense,
      incomeCategories: optimisticIncome,
    ));

    try {
      await _categoryRepository.update(category);
      await loadCategories();
    } catch (error) {
      emit(currentState);
    }
  }

  Future<void> deleteCategory(String id) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    // Optimistic: remove from lists immediately
    final optimisticExpense = currentState.expenseCategories
        .where((c) => c.id != id)
        .toList();
    final optimisticIncome = currentState.incomeCategories
        .where((c) => c.id != id)
        .toList();

    emit(currentState.copyWith(
      expenseCategories: optimisticExpense,
      incomeCategories: optimisticIncome,
    ));

    try {
      await _categoryRepository.delete(id);
    } catch (error) {
      emit(currentState);
    }
  }
}
