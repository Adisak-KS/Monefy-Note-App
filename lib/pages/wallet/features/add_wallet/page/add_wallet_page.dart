import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/models/currency.dart';
import '../../../../../core/models/wallet.dart';
import '../../../../../core/models/wallet_type.dart';
import '../../../../../core/widgets/color_picker_dialog.dart';
import '../../../../../core/widgets/icon_picker_sheet.dart';

class AddWalletPage extends StatefulWidget {
  final Wallet? wallet; // null for add, non-null for edit

  const AddWalletPage({super.key, this.wallet});

  static Future<Wallet?> navigate(BuildContext context, {Wallet? wallet}) {
    return Navigator.push<Wallet>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddWalletPage(wallet: wallet),
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
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late WalletType _selectedType;
  late Color _selectedColor;
  late bool _includeInTotal;
  late Currency _selectedCurrency;
  int? _selectedIconCodePoint; // Custom icon, null = use WalletType default

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

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet?.balance.toStringAsFixed(2) ?? '',
    );
    _selectedType = widget.wallet?.type ?? WalletType.cash;
    _selectedColor = widget.wallet?.color != null
        ? _parseColor(widget.wallet!.color!)
        : _colorOptions[0];
    _includeInTotal = widget.wallet?.includeInTotal ?? true;
    _selectedCurrency = Currency.fromCode(widget.wallet?.currency ?? 'THB');
    _selectedIconCodePoint = widget.wallet?.iconCodePoint;

    // Add listeners for real-time preview
    _nameController.addListener(_onFieldChanged);
    _balanceController.addListener(_onFieldChanged);

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
    _balanceController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _balanceController.dispose();
    _animController.dispose();
    super.dispose();
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
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
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
          _isEditing ? 'wallet.edit_wallet'.tr() : 'wallet.add_wallet'.tr(),
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
              _buildSectionLabel(theme, 'wallet.name'.tr(), Icons.label_rounded),
              const SizedBox(height: 12),
              _buildNameField(theme, isDark),
              const SizedBox(height: 24),

              // Type Selector
              _buildSectionLabel(theme, 'wallet.type'.tr(), Icons.category_rounded),
              const SizedBox(height: 12),
              _buildTypeSelector(theme),
              const SizedBox(height: 24),

              // Icon Selector
              _buildSectionLabel(theme, 'wallet.type_icon'.tr(), Icons.emoji_emotions_rounded),
              const SizedBox(height: 12),
              _buildIconSelector(theme),
              const SizedBox(height: 24),

              // Currency & Balance Row
              Row(
                children: [
                  // Currency Selector
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(theme, 'wallet.currency'.tr(), Icons.currency_exchange_rounded),
                        const SizedBox(height: 12),
                        _buildCurrencySelector(theme, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Balance Field
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel(theme, 'wallet.initial_balance'.tr(), Icons.attach_money_rounded),
                        const SizedBox(height: 12),
                        _buildBalanceField(theme, isDark),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Color Picker
              _buildSectionLabel(theme, 'wallet.color'.tr(), Icons.palette_rounded),
              const SizedBox(height: 12),
              _buildColorPicker(theme),
              const SizedBox(height: 24),

              // Include in Total Toggle
              _buildIncludeInTotalToggle(theme),
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
    final walletName = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0;
    final hasName = walletName.isNotEmpty;

    // Use custom icon if selected, otherwise use wallet type default icon
    final displayIcon = _selectedIconCodePoint != null
        ? IconData(_selectedIconCodePoint!, fontFamily: 'MaterialIcons')
        : _getTypeIcon(_selectedType);

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
                displayIcon,
                key: ValueKey(displayIcon.codePoint),
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
                // Wallet name or placeholder
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    hasName ? walletName : 'wallet.name_hint'.tr(),
                    key: ValueKey(hasName),  // Only animate when switching between placeholder/text
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: hasName ? 1.0 : 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                // Type and balance info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeName(_selectedType),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCurrency.format(balance),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Include in total indicator
          if (!_includeInTotal)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.visibility_off_rounded,
                color: Colors.white70,
                size: 18,
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
          hintText: 'wallet.name_hint'.tr(),
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
              Icons.account_balance_wallet_rounded,
              color: _selectedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showTypeBottomSheet(theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getTypeIcon(_selectedType),
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            // Type name and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTypeName(_selectedType),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _selectedType.isLiability
                        ? 'wallet.liabilities'.tr()
                        : 'wallet.assets'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _selectedType.isLiability
                          ? const Color(0xFFEF4444).withValues(alpha: 0.8)
                          : const Color(0xFF22C55E).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron icon
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final displayIcon = _selectedIconCodePoint != null
        ? IconData(_selectedIconCodePoint!, fontFamily: 'MaterialIcons')
        : _getTypeIcon(_selectedType);
    final hasCustomIcon = _selectedIconCodePoint != null;

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
                displayIcon,
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
                  Row(
                    children: [
                      Text(
                        'wallet.tap_change_icon'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasCustomIcon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Custom',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _selectedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
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
            // Reset button if custom icon is selected
            if (hasCustomIcon)
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedIconCodePoint = null);
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
                tooltip: 'Reset to default',
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

    final currentIcon = _selectedIconCodePoint != null
        ? IconData(_selectedIconCodePoint!, fontFamily: 'MaterialIcons')
        : _getTypeIcon(_selectedType);

    final result = await showIconPicker(
      context: context,
      selectedIcon: currentIcon,
      accentColor: _selectedColor,
    );

    if (result != null) {
      HapticFeedback.mediumImpact();
      setState(() => _selectedIconCodePoint = result.codePoint);
    }
  }

  void _showTypeBottomSheet(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'wallet.type'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'wallet.select_type'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            // Grid of wallet types
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assets section
                    _buildTypeSectionHeader(theme, 'wallet.assets'.tr(), Icons.trending_up_rounded, const Color(0xFF22C55E)),
                    const SizedBox(height: 12),
                    _buildTypeGrid(
                      theme,
                      WalletType.values.where((t) => !t.isLiability).toList(),
                      isDark,
                    ),
                    const SizedBox(height: 24),
                    // Liabilities section
                    _buildTypeSectionHeader(theme, 'wallet.liabilities'.tr(), Icons.trending_down_rounded, const Color(0xFFEF4444)),
                    const SizedBox(height: 12),
                    _buildTypeGrid(
                      theme,
                      WalletType.values.where((t) => t.isLiability).toList(),
                      isDark,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSectionHeader(ThemeData theme, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeGrid(ThemeData theme, List<WalletType> types, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = type == _selectedType;
        final color = type.color;

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _selectedType = type);
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : theme.colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    type.icon,
                    color: isSelected ? Colors.white : color,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    _getTypeName(type),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : null,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelector(ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => _showCurrencyPicker(theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(
              _selectedCurrency.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedCurrency.code,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_exchange_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'wallet.currency'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'wallet.select_currency'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
            // Currency list
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: Currency.values.length,
                itemBuilder: (context, index) {
                  final currency = Currency.values[index];
                  final isSelected = currency == _selectedCurrency;

                  return ListTile(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedCurrency = currency);
                      Navigator.pop(context);
                    },
                    leading: Text(
                      currency.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      currency.code,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? _selectedColor : null,
                      ),
                    ),
                    subtitle: Text(
                      currency.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          )
                        : Text(
                            currency.symbol,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceField(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: TextField(
        controller: _balanceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: _selectedColor,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          prefixText: '${_selectedCurrency.symbol} ',
          prefixStyle: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: _selectedColor.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
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

  Widget _buildIncludeInTotalToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _includeInTotal
              ? _selectedColor.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: _includeInTotal ? 2 : 1,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          'wallet.include_in_total'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'wallet.include_in_total_hint'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        value: _includeInTotal,
        onChanged: (value) {
          HapticFeedback.lightImpact();
          setState(() => _includeInTotal = value);
        },
        activeTrackColor: _selectedColor.withValues(alpha: 0.5),
        activeThumbColor: _selectedColor,
        inactiveThumbColor: theme.colorScheme.outline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _saveWallet,
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
              _isEditing ? 'common.save'.tr() : 'wallet.add_wallet'.tr(),
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

  void _saveWallet() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('wallet.error_name_required'.tr()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final balance = double.tryParse(_balanceController.text) ?? 0;

    final wallet = Wallet(
      id: widget.wallet?.id ?? const Uuid().v4(),
      name: name,
      type: _selectedType,
      balance: balance,
      currency: _selectedCurrency.code,
      includeInTotal: _includeInTotal,
      color: _colorToHex(_selectedColor),
      iconCodePoint: _selectedIconCodePoint,
    );

    HapticFeedback.mediumImpact();
    Navigator.pop(context, wallet);
  }

  String _getTypeName(WalletType type) {
    switch (type) {
      case WalletType.cash:
        return 'wallet.type_cash'.tr();
      case WalletType.bank:
        return 'wallet.type_bank'.tr();
      case WalletType.creditCard:
        return 'wallet.type_credit_card'.tr();
      case WalletType.eWallet:
        return 'wallet.type_ewallet'.tr();
      case WalletType.investment:
        return 'wallet.type_investment'.tr();
      case WalletType.debt:
        return 'wallet.type_debt'.tr();
      case WalletType.crypto:
        return 'wallet.type_crypto'.tr();
      case WalletType.savings:
        return 'wallet.type_savings'.tr();
      case WalletType.loan:
        return 'wallet.type_loan'.tr();
      case WalletType.insurance:
        return 'wallet.type_insurance'.tr();
      case WalletType.gold:
        return 'wallet.type_gold'.tr();
    }
  }

  IconData _getTypeIcon(WalletType type) {
    return type.icon;
  }
}
