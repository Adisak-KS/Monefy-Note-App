import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/models/custom_wallet_type.dart';
import '../../../../../core/widgets/color_picker_dialog.dart';
import '../../../../../core/widgets/icon_picker_sheet.dart';

class AddWalletTypePage extends StatefulWidget {
  final CustomWalletType? walletType;

  const AddWalletTypePage({super.key, this.walletType});

  static Future<CustomWalletType?> navigate(
    BuildContext context, {
    CustomWalletType? walletType,
  }) {
    return Navigator.push<CustomWalletType>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddWalletTypePage(walletType: walletType),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<AddWalletTypePage> createState() => _AddWalletTypePageState();
}

class _AddWalletTypePageState extends State<AddWalletTypePage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late bool _isLiability;

  final List<Color> _colorOptions = [
    // Primary Colors
    const Color(0xFF22C55E), // Green
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEF4444), // Red
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFEC4899), // Pink
    const Color(0xFF14B8A6), // Teal
    // Additional Colors
    const Color(0xFF10B981), // Emerald
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFF97316), // Orange
    const Color(0xFF84CC16), // Lime
    const Color(0xFFA855F7), // Violet
    const Color(0xFF0EA5E9), // Sky
    const Color(0xFFE11D48), // Rose
    const Color(0xFF78716C), // Stone
  ];

  bool get _isEditing => widget.walletType != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.walletType?.name ?? '');
    _selectedIcon = widget.walletType != null
        ? _parseIcon(widget.walletType!.iconName)
        : Icons.account_balance_wallet_rounded;
    _selectedColor = widget.walletType != null
        ? _parseColor(widget.walletType!.colorHex)
        : _colorOptions[0];
    _isLiability = widget.walletType?.isLiability ?? false;

    // Add listener for real-time preview
    _nameController.addListener(_onFieldChanged);

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  IconData _parseIcon(String iconName) {
    try {
      final codePoint = int.parse(iconName);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.account_balance_wallet_rounded;
    }
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return _colorOptions[0];
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        title: Text(
          _isEditing
              ? 'wallet.edit_wallet_type'.tr()
              : 'wallet.add_wallet_type'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              _buildHeaderCard(theme, isDark),
              const SizedBox(height: 32),

              // Name Field
              _buildSectionLabel(
                  theme, 'wallet.type_name'.tr(), Icons.label_rounded),
              const SizedBox(height: 12),
              _buildNameField(theme, isDark),
              const SizedBox(height: 24),

              // Icon Selector
              _buildSectionLabel(
                  theme, 'wallet.type_icon'.tr(), Icons.emoji_emotions_rounded),
              const SizedBox(height: 12),
              _buildIconSelector(theme),
              const SizedBox(height: 24),

              // Color Picker
              _buildSectionLabel(
                  theme, 'wallet.color'.tr(), Icons.palette_rounded),
              const SizedBox(height: 12),
              _buildColorPicker(theme),
              const SizedBox(height: 24),

              // Is Liability Toggle
              _buildIsLiabilityToggle(theme),
              const SizedBox(height: 40),

              // Save Button
              _buildSaveButton(theme),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, bool isDark) {
    final typeName = _nameController.text.trim();
    final hasName = typeName.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _selectedColor,
            _selectedColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon preview with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                _selectedIcon,
                key: ValueKey(_selectedIcon),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type name preview or placeholder
                Text(
                  hasName ? typeName : 'wallet.type_name_hint'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: hasName ? 1.0 : 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Category badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'wallet.custom_types'.tr(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Liability badge
                    if (_isLiability)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_down_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'wallet.liabilities'.tr(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: _selectedColor,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'wallet.type_name_hint'.tr(),
          hintStyle: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              _selectedIcon,
              color: _selectedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _pickIcon,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Selected icon preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _selectedIcon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'wallet.tap_change_icon'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'wallet.search_icons'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    HapticFeedback.lightImpact();

    final result = await showIconPicker(
      context: context,
      selectedIcon: _selectedIcon,
      accentColor: _selectedColor,
    );

    if (result != null) {
      HapticFeedback.mediumImpact();
      setState(() => _selectedIcon = result);
    }
  }

  Widget _buildColorPicker(ThemeData theme) {
    final colorWidgets = _colorOptions.map((color) {
      final isSelected = color.toARGB32() == _selectedColor.toARGB32();
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedColor = color);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.onSurface,
                    width: 3,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isSelected ? 0.5 : 0.3),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isSelected
              ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24,
                )
              : null,
        ),
      );
    }).toList();

    // Custom color picker button
    final isCustomColor = !_colorOptions.any(
      (c) => c.toARGB32() == _selectedColor.toARGB32(),
    );
    final customColorButton = GestureDetector(
      onTap: _showCustomColorPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: isCustomColor
              ? LinearGradient(
                  colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isCustomColor ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCustomColor
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isCustomColor ? 3 : 2,
          ),
          boxShadow: isCustomColor
              ? [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          isCustomColor ? Icons.check_rounded : Icons.colorize_rounded,
          color: isCustomColor
              ? Colors.white
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [...colorWidgets, customColorButton],
    );
  }

  Future<void> _showCustomColorPicker() async {
    final result = await showColorPickerDialog(
      context: context,
      initialColor: _selectedColor,
    );

    if (result != null) {
      setState(() => _selectedColor = result);
    }
  }

  Widget _buildIsLiabilityToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isLiability
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: _isLiability ? 2 : 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'wallet.is_liability'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'wallet.is_liability_hint'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        value: _isLiability,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          setState(() => _isLiability = value);
        },
        activeTrackColor: const Color(0xFFEF4444).withValues(alpha: 0.5),
        activeThumbColor: const Color(0xFFEF4444),
        inactiveThumbColor: theme.colorScheme.outline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _saveType,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: _selectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEditing ? Icons.save_rounded : Icons.add_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isEditing ? 'common.save'.tr() : 'wallet.add_wallet_type'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveType() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('wallet.error_type_name_required'.tr()),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final customType = CustomWalletType(
      id: widget.walletType?.id ?? const Uuid().v4(),
      name: name,
      iconName: _selectedIcon.codePoint.toString(),
      colorHex: _colorToHex(_selectedColor),
      isLiability: _isLiability,
      createdAt: widget.walletType?.createdAt,
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, customType);
  }
}
