import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'drawer_stats_state.dart';

@lazySingleton
class DrawerStatsCubit extends Cubit<DrawerStatsState> {
  DrawerStatsCubit() : super(const DrawerStatsState());

  void updateStats({
    required double totalIncome,
    required double totalExpense,
    required int transactionCount,
  }) {
    emit(state.copyWith(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      transactionCount: transactionCount,
      isLoading: false,
    ));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }

  void reset() {
    emit(const DrawerStatsState());
  }
}
