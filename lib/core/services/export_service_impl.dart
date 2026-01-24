import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/wallet.dart';
import '../models/wallet_type.dart';
import 'export_service.dart';

@LazySingleton(as: ExportService)
class ExportServiceImpl implements ExportService {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  final _currencyFormat = NumberFormat('#,##0.00');

  Future<String> _getExportDirectory() async {
    final directory = await getTemporaryDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  String _generateFileName(String prefix, String extension) {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${prefix}_$timestamp.$extension';
  }

  // ==================== TRANSACTIONS ====================

  @override
  Future<String> exportTransactionsToExcel(
    List<Transaction> transactions,
    DateTimeRange range,
  ) async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Transactions';

    // Header style
    final headerStyle = workbook.styles.add('headerStyle');
    headerStyle.bold = true;
    headerStyle.backColor = '#4CAF50';
    headerStyle.fontColor = '#FFFFFF';

    // Headers
    final headers = ['Date', 'Type', 'Category', 'Wallet', 'Amount', 'Description'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(1, i + 1).cellStyle = headerStyle;
    }

    // Data
    for (var i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(_dateFormat.format(tx.date));
      sheet.getRangeByIndex(row, 2).setText(tx.type == TransactionType.income ? 'Income' : 'Expense');
      sheet.getRangeByIndex(row, 3).setText(tx.category?.name ?? tx.categoryId);
      sheet.getRangeByIndex(row, 4).setText(tx.wallet?.name ?? tx.walletId);
      sheet.getRangeByIndex(row, 5).setNumber(tx.type == TransactionType.expense ? -tx.amount : tx.amount);
      sheet.getRangeByIndex(row, 6).setText(tx.description ?? '');
    }

    // Auto-fit columns
    for (var i = 1; i <= headers.length; i++) {
      sheet.autoFitColumn(i);
    }

    // Save
    final dir = await _getExportDirectory();
    final fileName = _generateFileName('transactions', 'xlsx');
    final filePath = '$dir/$fileName';
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  @override
  Future<String> exportTransactionsToCsv(
    List<Transaction> transactions,
    DateTimeRange range,
  ) async {
    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Category', 'Wallet', 'Amount', 'Description'],
    ];

    for (final tx in transactions) {
      rows.add([
        _dateFormat.format(tx.date),
        tx.type == TransactionType.income ? 'Income' : 'Expense',
        tx.category?.name ?? tx.categoryId,
        tx.wallet?.name ?? tx.walletId,
        tx.type == TransactionType.expense ? -tx.amount : tx.amount,
        tx.description ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await _getExportDirectory();
    final fileName = _generateFileName('transactions', 'csv');
    final filePath = '$dir/$fileName';

    final file = File(filePath);
    await file.writeAsString(csv);
    return filePath;
  }

  @override
  Future<String> exportTransactionsToPdf(
    List<Transaction> transactions,
    DateTimeRange range,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Transactions Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${_dateFormat.format(range.start)} - ${_dateFormat.format(range.end)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Date', 'Type', 'Category', 'Wallet', 'Amount'],
            data: transactions.map((tx) => [
              _dateFormat.format(tx.date),
              tx.type == TransactionType.income ? 'Income' : 'Expense',
              tx.category?.name ?? tx.categoryId,
              tx.wallet?.name ?? tx.walletId,
              '${tx.type == TransactionType.expense ? "-" : ""}${_currencyFormat.format(tx.amount)}',
            ]).toList(),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ),
    );

    final dir = await _getExportDirectory();
    final fileName = _generateFileName('transactions', 'pdf');
    final filePath = '$dir/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  // ==================== WALLETS ====================

  @override
  Future<String> exportWalletsToExcel(List<Wallet> wallets) async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Wallets';

    // Header style
    final headerStyle = workbook.styles.add('headerStyle');
    headerStyle.bold = true;
    headerStyle.backColor = '#2196F3';
    headerStyle.fontColor = '#FFFFFF';

    // Headers
    final headers = ['Name', 'Type', 'Balance', 'Currency', 'Include in Total', 'Archived'];
    for (var i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(1, i + 1).cellStyle = headerStyle;
    }

    // Data
    for (var i = 0; i < wallets.length; i++) {
      final wallet = wallets[i];
      final row = i + 2;
      sheet.getRangeByIndex(row, 1).setText(wallet.name);
      sheet.getRangeByIndex(row, 2).setText(wallet.type.value);
      sheet.getRangeByIndex(row, 3).setNumber(wallet.balance);
      sheet.getRangeByIndex(row, 4).setText(wallet.currency);
      sheet.getRangeByIndex(row, 5).setText(wallet.includeInTotal ? 'Yes' : 'No');
      sheet.getRangeByIndex(row, 6).setText(wallet.isArchived ? 'Yes' : 'No');
    }

    // Auto-fit columns
    for (var i = 1; i <= headers.length; i++) {
      sheet.autoFitColumn(i);
    }

    // Save
    final dir = await _getExportDirectory();
    final fileName = _generateFileName('wallets', 'xlsx');
    final filePath = '$dir/$fileName';
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  @override
  Future<String> exportWalletsToCsv(List<Wallet> wallets) async {
    final rows = <List<dynamic>>[
      ['Name', 'Type', 'Balance', 'Currency', 'Include in Total', 'Archived'],
    ];

    for (final wallet in wallets) {
      rows.add([
        wallet.name,
        wallet.type.value,
        wallet.balance,
        wallet.currency,
        wallet.includeInTotal ? 'Yes' : 'No',
        wallet.isArchived ? 'Yes' : 'No',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await _getExportDirectory();
    final fileName = _generateFileName('wallets', 'csv');
    final filePath = '$dir/$fileName';

    final file = File(filePath);
    await file.writeAsString(csv);
    return filePath;
  }

  @override
  Future<String> exportWalletsToPdf(List<Wallet> wallets) async {
    final pdf = pw.Document();

    final totalBalance = wallets
        .where((w) => w.includeInTotal && !w.isArchived)
        .fold(0.0, (sum, w) => sum + w.balance);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Wallets Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${_dateTimeFormat.format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Total Balance: ${_currencyFormat.format(totalBalance)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Name', 'Type', 'Balance', 'Currency'],
            data: wallets.map((w) => [
              w.name,
              w.type.value,
              _currencyFormat.format(w.balance),
              w.currency,
            ]).toList(),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ),
    );

    final dir = await _getExportDirectory();
    final fileName = _generateFileName('wallets', 'pdf');
    final filePath = '$dir/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  // ==================== SUMMARY ====================

  @override
  Future<String> exportSummaryToExcel(
    SummaryData data,
    DateTimeRange range,
  ) async {
    final workbook = xlsio.Workbook();

    // Summary sheet
    final summarySheet = workbook.worksheets[0];
    summarySheet.name = 'Summary';

    final headerStyle = workbook.styles.add('headerStyle');
    headerStyle.bold = true;
    headerStyle.backColor = '#9C27B0';
    headerStyle.fontColor = '#FFFFFF';

    summarySheet.getRangeByIndex(1, 1).setText('Summary Report');
    summarySheet.getRangeByIndex(1, 1).cellStyle.bold = true;
    summarySheet.getRangeByIndex(1, 1).cellStyle.fontSize = 16;

    summarySheet.getRangeByIndex(2, 1).setText('Period:');
    summarySheet.getRangeByIndex(2, 2).setText(
      '${_dateFormat.format(range.start)} - ${_dateFormat.format(range.end)}',
    );

    summarySheet.getRangeByIndex(4, 1).setText('Total Income:');
    summarySheet.getRangeByIndex(4, 2).setNumber(data.totalIncome);

    summarySheet.getRangeByIndex(5, 1).setText('Total Expense:');
    summarySheet.getRangeByIndex(5, 2).setNumber(data.totalExpense);

    summarySheet.getRangeByIndex(6, 1).setText('Balance:');
    summarySheet.getRangeByIndex(6, 2).setNumber(data.balance);
    summarySheet.getRangeByIndex(6, 2).cellStyle.bold = true;

    // Expense by category
    summarySheet.getRangeByIndex(8, 1).setText('Expenses by Category');
    summarySheet.getRangeByIndex(8, 1).cellStyle = headerStyle;
    summarySheet.getRangeByIndex(8, 2).setText('Amount');
    summarySheet.getRangeByIndex(8, 2).cellStyle = headerStyle;

    var row = 9;
    for (final entry in data.expenseByCategory.entries) {
      summarySheet.getRangeByIndex(row, 1).setText(entry.key);
      summarySheet.getRangeByIndex(row, 2).setNumber(entry.value);
      row++;
    }

    // Income by category
    row += 2;
    summarySheet.getRangeByIndex(row, 1).setText('Income by Category');
    summarySheet.getRangeByIndex(row, 1).cellStyle = headerStyle;
    summarySheet.getRangeByIndex(row, 2).setText('Amount');
    summarySheet.getRangeByIndex(row, 2).cellStyle = headerStyle;
    row++;

    for (final entry in data.incomeByCategory.entries) {
      summarySheet.getRangeByIndex(row, 1).setText(entry.key);
      summarySheet.getRangeByIndex(row, 2).setNumber(entry.value);
      row++;
    }

    summarySheet.autoFitColumn(1);
    summarySheet.autoFitColumn(2);

    // Transactions sheet
    final txSheet = workbook.worksheets.addWithName('Transactions');
    final headers = ['Date', 'Type', 'Category', 'Wallet', 'Amount', 'Description'];
    for (var i = 0; i < headers.length; i++) {
      txSheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      txSheet.getRangeByIndex(1, i + 1).cellStyle = headerStyle;
    }

    for (var i = 0; i < data.transactions.length; i++) {
      final tx = data.transactions[i];
      final r = i + 2;
      txSheet.getRangeByIndex(r, 1).setText(_dateFormat.format(tx.date));
      txSheet.getRangeByIndex(r, 2).setText(tx.type == TransactionType.income ? 'Income' : 'Expense');
      txSheet.getRangeByIndex(r, 3).setText(tx.category?.name ?? tx.categoryId);
      txSheet.getRangeByIndex(r, 4).setText(tx.wallet?.name ?? tx.walletId);
      txSheet.getRangeByIndex(r, 5).setNumber(tx.type == TransactionType.expense ? -tx.amount : tx.amount);
      txSheet.getRangeByIndex(r, 6).setText(tx.description ?? '');
    }

    for (var i = 1; i <= headers.length; i++) {
      txSheet.autoFitColumn(i);
    }

    // Save
    final dir = await _getExportDirectory();
    final fileName = _generateFileName('summary', 'xlsx');
    final filePath = '$dir/$fileName';
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  @override
  Future<String> exportSummaryToCsv(
    SummaryData data,
    DateTimeRange range,
  ) async {
    final rows = <List<dynamic>>[
      ['Summary Report'],
      ['Period', '${_dateFormat.format(range.start)} - ${_dateFormat.format(range.end)}'],
      [],
      ['Total Income', data.totalIncome],
      ['Total Expense', data.totalExpense],
      ['Balance', data.balance],
      [],
      ['Expenses by Category', 'Amount'],
    ];

    for (final entry in data.expenseByCategory.entries) {
      rows.add([entry.key, entry.value]);
    }

    rows.add([]);
    rows.add(['Income by Category', 'Amount']);

    for (final entry in data.incomeByCategory.entries) {
      rows.add([entry.key, entry.value]);
    }

    rows.add([]);
    rows.add(['Transactions']);
    rows.add(['Date', 'Type', 'Category', 'Wallet', 'Amount', 'Description']);

    for (final tx in data.transactions) {
      rows.add([
        _dateFormat.format(tx.date),
        tx.type == TransactionType.income ? 'Income' : 'Expense',
        tx.category?.name ?? tx.categoryId,
        tx.wallet?.name ?? tx.walletId,
        tx.type == TransactionType.expense ? -tx.amount : tx.amount,
        tx.description ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await _getExportDirectory();
    final fileName = _generateFileName('summary', 'csv');
    final filePath = '$dir/$fileName';

    final file = File(filePath);
    await file.writeAsString(csv);
    return filePath;
  }

  @override
  Future<String> exportSummaryToPdf(
    SummaryData data,
    DateTimeRange range,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Summary Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '${_dateFormat.format(range.start)} - ${_dateFormat.format(range.end)}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
          ],
        ),
        build: (context) => [
          // Overview
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Income', data.totalIncome, PdfColors.green),
                _buildSummaryItem('Expense', data.totalExpense, PdfColors.red),
                _buildSummaryItem('Balance', data.balance, PdfColors.blue),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Expense by category
          pw.Text(
            'Expenses by Category',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Category', 'Amount'],
            data: data.expenseByCategory.entries
                .map((e) => [e.key, _currencyFormat.format(e.value)])
                .toList(),
          ),
          pw.SizedBox(height: 24),

          // Income by category
          pw.Text(
            'Income by Category',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Category', 'Amount'],
            data: data.incomeByCategory.entries
                .map((e) => [e.key, _currencyFormat.format(e.value)])
                .toList(),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ),
    );

    final dir = await _getExportDirectory();
    final fileName = _generateFileName('summary', 'pdf');
    final filePath = '$dir/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  pw.Widget _buildSummaryItem(String label, double value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _currencyFormat.format(value),
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
