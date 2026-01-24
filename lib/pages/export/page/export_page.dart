import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/export_service.dart';
import '../../../core/widgets/page_gradient_background.dart';
import '../../../injection.dart';
import '../bloc/export_cubit.dart';
import '../bloc/export_state.dart';
import '../widgets/data_type_selector.dart';
import '../widgets/date_range_selector.dart';
import '../widgets/format_selector.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ExportCubit>(),
      child: const _ExportPageContent(),
    );
  }
}

class _ExportPageContent extends StatelessWidget {
  const _ExportPageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const PageGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'export.title'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: BlocConsumer<ExportCubit, ExportState>(
                    listener: (context, state) {
                      if (state is ExportSuccess) {
                        _showSuccessDialog(context, state.filePath);
                      } else if (state is ExportError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('export.error'.tr()),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Data Type Selector
                            DataTypeSelector(
                              selectedType: state.dataType,
                              onChanged: (type) {
                                context.read<ExportCubit>().setDataType(type);
                              },
                            ),
                            const SizedBox(height: 24),

                            // Date Range Selector (only for transactions and summary)
                            if (state.dataType != ExportDataType.wallets) ...[
                              DateRangeSelector(
                                selectedRange: state.dateRange,
                                onThisMonth: () {
                                  context.read<ExportCubit>().setThisMonth();
                                },
                                onLastMonth: () {
                                  context.read<ExportCubit>().setLastMonth();
                                },
                                onThisYear: () {
                                  context.read<ExportCubit>().setThisYear();
                                },
                                onCustomRange: (range) {
                                  context.read<ExportCubit>().setDateRange(range);
                                },
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Format Selector
                            FormatSelector(
                              selectedFormat: state.format,
                              onChanged: (format) {
                                context.read<ExportCubit>().setFormat(format);
                              },
                            ),
                            const SizedBox(height: 32),

                            // Export Button
                            FilledButton.icon(
                              onPressed: state is ExportLoading
                                  ? null
                                  : () => context.read<ExportCubit>().export(),
                              icon: state is ExportLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.file_download_rounded),
                              label: Text(
                                state is ExportLoading
                                    ? 'export.exporting'.tr()
                                    : 'export.export_button'.tr(),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String filePath) {
    final theme = Theme.of(context);
    final cubit = context.read<ExportCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text('export.success'.tr()),
        content: Text(
          'export.file_ready'.tr(),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.reset();
            },
            child: Text('common.close'.tr()),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.shareFile(filePath);
              cubit.reset();
            },
            icon: const Icon(Icons.share_rounded),
            label: Text('export.share'.tr()),
          ),
        ],
      ),
    );
  }
}
