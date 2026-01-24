import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/repositories/category_repository.dart';
import 'category_state.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;
  static const _uuid = Uuid();

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
    if (state is! CategoryLoaded) return;

    try {
      final newCategory = Category(
        id: _uuid.v4(),
        name: name,
        type: type,
        icon: icon,
        color: color,
      );

      await _categoryRepository.add(newCategory);
      await loadCategories();
    } catch (error) {
      emit(CategoryError(error.toString()));
    }
  }

  Future<void> updateCategory(Category category) async {
    if (state is! CategoryLoaded) return;

    try {
      await _categoryRepository.update(category);
      await loadCategories();
    } catch (error) {
      emit(CategoryError(error.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    if (state is! CategoryLoaded) return;

    try {
      await _categoryRepository.delete(id);
      await loadCategories();
    } catch (error) {
      emit(CategoryError(error.toString()));
    }
  }
}
