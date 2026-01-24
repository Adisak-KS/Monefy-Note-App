import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

/// Data model for summary report export
class SummaryData {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final List<Transaction> transactions;

  const SummaryData({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.transactions,
  });
}

/// Export format types
enum ExportFormat { excel, csv, pdf }

/// Export data type
enum ExportDataType { transactions, wallets, summary }

/// Service for exporting data to various formats
abstract class ExportService {
  /// Export transactions to Excel format
  Future<String> exportTransactionsToExcel(
    List<Transaction> transactions,
    DateTimeRange range,
  );

  /// Export transactions to CSV format
  Future<String> exportTransactionsToCsv(
    List<Transaction> transactions,
    DateTimeRange range,
  );

  /// Export transactions to PDF format
  Future<String> exportTransactionsToPdf(
    List<Transaction> transactions,
    DateTimeRange range,
  );

  /// Export wallets to Excel format
  Future<String> exportWalletsToExcel(List<Wallet> wallets);

  /// Export wallets to CSV format
  Future<String> exportWalletsToCsv(List<Wallet> wallets);

  /// Export wallets to PDF format
  Future<String> exportWalletsToPdf(List<Wallet> wallets);

  /// Export summary report to PDF format
  Future<String> exportSummaryToPdf(
    SummaryData data,
    DateTimeRange range,
  );

  /// Export summary report to Excel format
  Future<String> exportSummaryToExcel(
    SummaryData data,
    DateTimeRange range,
  );

  /// Export summary report to CSV format
  Future<String> exportSummaryToCsv(
    SummaryData data,
    DateTimeRange range,
  );
}
