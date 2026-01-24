import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/services/export_service.dart';
import '../../../core/theme/app_colors.dart';

class FormatSelector extends StatelessWidget {
  final ExportFormat selectedFormat;
  final ValueChanged<ExportFormat> onChanged;

  const FormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'export.select_format'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFormatCard(
                context,
                format: ExportFormat.excel,
                icon: Icons.table_chart_rounded,
                label: 'Excel',
                extension: '.xlsx',
                color: AppColors.excel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatCard(
                context,
                format: ExportFormat.csv,
                icon: Icons.description_rounded,
                label: 'CSV',
                extension: '.csv',
                color: AppColors.csv,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFormatCard(
                context,
                format: ExportFormat.pdf,
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF',
                extension: '.pdf',
                color: AppColors.pdf,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard(
    BuildContext context, {
    required ExportFormat format,
    required IconData icon,
    required String label,
    required String extension,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = selectedFormat == format;

    return InkWell(
      onTap: () => onChanged(format),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              extension,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
