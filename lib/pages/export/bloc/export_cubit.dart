import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/repositories/transaction_repository.dart';
import '../../../core/repositories/wallet_repository.dart';
import '../../../core/services/export_service.dart';
import 'export_state.dart';

@injectable
class ExportCubit extends Cubit<ExportState> {
  final ExportService _exportService;
  final TransactionRepository _transactionRepository;
  final WalletRepository _walletRepository;

  ExportCubit(
    this._exportService,
    this._transactionRepository,
    this._walletRepository,
  ) : super(ExportState.initial(
          dateRange: DateTimeRange(
            start: DateTime(DateTime.now().year, DateTime.now().month, 1),
            end: DateTime.now(),
          ),
        ));

  void setDataType(ExportDataType dataType) {
    final currentState = state;
    emit(ExportState.initial(
      dataType: dataType,
      format: currentState.format,
      dateRange: currentState.dateRange,
    ));
  }

  void setFormat(ExportFormat format) {
    final currentState = state;
    emit(ExportState.initial(
      dataType: currentState.dataType,
      format: format,
      dateRange: currentState.dateRange,
    ));
  }

  void setDateRange(DateTimeRange range) {
    final currentState = state;
    emit(ExportState.initial(
      dataType: currentState.dataType,
      format: currentState.format,
      dateRange: range,
    ));
  }

  void setThisMonth() {
    final now = DateTime.now();
    setDateRange(DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    ));
  }

  void setLastMonth() {
    final now = DateTime.now();
    setDateRange(DateTimeRange(
      start: DateTime(now.year, now.month - 1, 1),
      end: DateTime(now.year, now.month, 0),
    ));
  }

  void setThisYear() {
    final now = DateTime.now();
    setDateRange(DateTimeRange(
      start: DateTime(now.year, 1, 1),
      end: DateTime(now.year, 12, 31),
    ));
  }

  Future<void> export() async {
    final dataType = state.dataType;
    final format = state.format;
    final dateRange = state.dateRange;

    emit(ExportState.loading(
      dataType: dataType,
      format: format,
      dateRange: dateRange,
    ));

    try {
      String filePath;

      switch (dataType) {
        case ExportDataType.transactions:
          filePath = await _exportTransactions(format, dateRange!);
        case ExportDataType.wallets:
          filePath = await _exportWallets(format);
        case ExportDataType.summary:
          filePath = await _exportSummary(format, dateRange!);
      }

      emit(ExportState.success(
        filePath: filePath,
        dataType: dataType,
        format: format,
        dateRange: dateRange,
      ));
    } catch (e) {
      emit(ExportState.error(
        message: e.toString(),
        dataType: dataType,
        format: format,
        dateRange: dateRange,
      ));
    }
  }

  Future<String> _exportTransactions(
    ExportFormat format,
    DateTimeRange range,
  ) async {
    final transactions = await _transactionRepository.getByDateRange(
      range.start,
      range.end,
    );

    switch (format) {
      case ExportFormat.excel:
        return _exportService.exportTransactionsToExcel(transactions, range);
      case ExportFormat.csv:
        return _exportService.exportTransactionsToCsv(transactions, range);
      case ExportFormat.pdf:
        return _exportService.exportTransactionsToPdf(transactions, range);
    }
  }

  Future<String> _exportWallets(ExportFormat format) async {
    final wallets = await _walletRepository.getAll();

    switch (format) {
      case ExportFormat.excel:
        return _exportService.exportWalletsToExcel(wallets);
      case ExportFormat.csv:
        return _exportService.exportWalletsToCsv(wallets);
      case ExportFormat.pdf:
        return _exportService.exportWalletsToPdf(wallets);
    }
  }

  Future<String> _exportSummary(
    ExportFormat format,
    DateTimeRange range,
  ) async {
    final transactions = await _transactionRepository.getByDateRange(
      range.start,
      range.end,
    );

    // Calculate totals and group by category
    double totalIncome = 0;
    double totalExpense = 0;
    final expenseByCategory = <String, double>{};
    final incomeByCategory = <String, double>{};

    for (final tx in transactions) {
      final categoryName = tx.category?.name ?? 'Unknown';
      if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
        expenseByCategory[categoryName] =
            (expenseByCategory[categoryName] ?? 0) + tx.amount;
      } else {
        totalIncome += tx.amount;
        incomeByCategory[categoryName] =
            (incomeByCategory[categoryName] ?? 0) + tx.amount;
      }
    }

    final summaryData = SummaryData(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      expenseByCategory: expenseByCategory,
      incomeByCategory: incomeByCategory,
      transactions: transactions,
    );

    switch (format) {
      case ExportFormat.excel:
        return _exportService.exportSummaryToExcel(summaryData, range);
      case ExportFormat.csv:
        return _exportService.exportSummaryToCsv(summaryData, range);
      case ExportFormat.pdf:
        return _exportService.exportSummaryToPdf(summaryData, range);
    }
  }

  Future<void> shareFile(String filePath) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(filePath)]));
  }

  void reset() {
    emit(ExportState.initial(
      dateRange: DateTimeRange(
        start: DateTime(DateTime.now().year, DateTime.now().month, 1),
        end: DateTime.now(),
      ),
    ));
  }
}
