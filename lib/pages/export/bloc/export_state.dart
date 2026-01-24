import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/services/export_service.dart';

part 'export_state.freezed.dart';

@freezed
sealed class ExportState with _$ExportState {
  const factory ExportState.initial({
    @Default(ExportDataType.transactions) ExportDataType dataType,
    @Default(ExportFormat.excel) ExportFormat format,
    DateTimeRange? dateRange,
  }) = ExportInitial;

  const factory ExportState.loading({
    required ExportDataType dataType,
    required ExportFormat format,
    DateTimeRange? dateRange,
  }) = ExportLoading;

  const factory ExportState.success({
    required String filePath,
    required ExportDataType dataType,
    required ExportFormat format,
    DateTimeRange? dateRange,
  }) = ExportSuccess;

  const factory ExportState.error({
    required String message,
    required ExportDataType dataType,
    required ExportFormat format,
    DateTimeRange? dateRange,
  }) = ExportError;
}
