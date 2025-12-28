import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Shows a custom color picker dialog and returns the selected color
/// Returns null if cancelled
Future<Color?> showColorPickerDialog({
  required BuildContext context,
  required Color initialColor,
}) async {
  Color? selectedColor;
  final theme = Theme.of(context);

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Custom Color Picker',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return _ColorPickerDialogContent(
        initialColor: initialColor,
        theme: theme,
        onColorSelected: (color) {
          selectedColor = color;
        },
      );
    },
  );

  return selectedColor;
}

class _ColorPickerDialogContent extends StatefulWidget {
  final Color initialColor;
  final ThemeData theme;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialogContent({
    required this.initialColor,
    required this.theme,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialogContent> createState() =>
      _ColorPickerDialogContentState();
}

class _ColorPickerDialogContentState extends State<_ColorPickerDialogContent> {
  late Color _pickerColor;
  int _selectedPickerType = 0;

  @override
  void initState() {
    super.initState();
    _pickerColor = widget.initialColor;
  }

  bool get _isDark => widget.theme.brightness == Brightness.dark;

  String get _hexCode =>
      '#${_pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildPickerTabs(),
              _buildPickerContent(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _pickerColor,
            _pickerColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'wallet.custom_color'.tr(),
                  style: widget.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _hexCode,
                    style: widget.theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildPickerTab(
              label: 'Wheel',
              icon: Icons.donut_large_rounded,
              index: 0,
            ),
            _buildPickerTab(
              label: 'Material',
              icon: Icons.grid_view_rounded,
              index: 1,
            ),
            _buildPickerTab(
              label: 'Block',
              icon: Icons.view_module_rounded,
              index: 2,
            ),
            _buildPickerTab(
              label: 'Slider',
              icon: Icons.tune_rounded,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTab({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _selectedPickerType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedPickerType = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _pickerColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _pickerColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (_isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (_isDark ? Colors.white54 : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerContent() {
    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          key: ValueKey(_selectedPickerType),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: _buildColorPicker(),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final containerDecoration = BoxDecoration(
      color: _isDark
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.grey.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
    );

    switch (_selectedPickerType) {
      case 0: // Color Wheel
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: containerDecoration,
          child: ColorPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) => setState(() => _pickerColor = color),
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
            colorPickerWidth: 280,
            displayThumbColor: true,
            portraitOnly: true,
          ),
        );
      case 1: // Material Picker
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: containerDecoration,
          child: MaterialPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) => setState(() => _pickerColor = color),
            enableLabel: true,
          ),
        );
      case 2: // Block Picker
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: containerDecoration,
          child: BlockPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) => setState(() => _pickerColor = color),
            layoutBuilder: (context, colors, child) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: colors.map((color) => child(color)).toList(),
              );
            },
            itemBuilder: (color, isCurrentColor, changeColor) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  changeColor();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isCurrentColor ? 48 : 44,
                  height: isCurrentColor ? 48 : 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(isCurrentColor ? 14 : 12),
                    border: isCurrentColor
                        ? Border.all(
                            color: _isDark ? Colors.white : Colors.black87,
                            width: 3,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color:
                            color.withValues(alpha: isCurrentColor ? 0.5 : 0.3),
                        blurRadius: isCurrentColor ? 12 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isCurrentColor
                      ? Icon(
                          Icons.check_rounded,
                          color: _getContrastColor(color),
                          size: 24,
                        )
                      : null,
                ),
              );
            },
          ),
        );
      case 3: // Slider Picker
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: containerDecoration,
          child: SlidePicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) => setState(() => _pickerColor = color),
            enableAlpha: false,
            showIndicator: true,
            indicatorBorderRadius: BorderRadius.circular(12),
            sliderSize: const Size(280, 40),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Text(
                'common.cancel'.tr(),
                style: TextStyle(
                  color: _isDark ? Colors.white70 : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onColorSelected(_pickerColor);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _pickerColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'common.save'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
