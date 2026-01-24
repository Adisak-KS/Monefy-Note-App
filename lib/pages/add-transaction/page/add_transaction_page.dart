import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/models/wallet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_utils.dart';
import '../../home/bloc/home_cubit.dart';
import '../../home/bloc/home_state.dart';
import '../widgets/amount_display.dart';
import '../widgets/calculator_keyboard.dart';
import '../widgets/category_grid.dart';

class AddTransactionPage extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionPage({super.key, this.existingTransaction});

  bool get isEditMode => existingTransaction != null;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  final _noteFocusNode = FocusNode();
  TransactionType _type = TransactionType.expense;
  Category? _selectedCategory;
  Wallet? _selectedWallet;
  DateTime _selectedDate = DateTime.now();
  final _descriptionController = TextEditingController();

  // Calculator state
  String _expression = '0';
  double _result = 0;
  bool _isNoteFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _noteFocusNode.addListener(_onNoteFocusChanged);

    final existing = widget.existingTransaction;
    if (existing != null) {
      _type = existing.type;
      _expression = _formatNumber(existing.amount);
      _result = existing.amount;
      _descriptionController.text = existing.description ?? '';
      _selectedDate = existing.date;
      _tabController.index = _type == TransactionType.expense ? 0 : 1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelections();
    });
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.truncate().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _initializeSelections() {
    final state = context.read<HomeCubit>().state;
    if (state is HomeLoaded) {
      setState(() {
        final existing = widget.existingTransaction;
        if (existing != null) {
          // Edit mode - find existing wallet/category or fallback to first
          final matchingWallet = state.wallets.where((w) => w.id == existing.walletId);
          _selectedWallet = matchingWallet.isNotEmpty
              ? matchingWallet.first
              : (state.wallets.isNotEmpty ? state.wallets.first : null);

          final matchingCategory = state.categories.where((c) => c.id == existing.categoryId);
          _selectedCategory = matchingCategory.isNotEmpty
              ? matchingCategory.first
              : (state.categories.isNotEmpty ? state.categories.first : null);
        } else {
          // New transaction - select first wallet and first category
          if (state.wallets.isNotEmpty) {
            _selectedWallet = state.wallets.first;
          }
          final categories = state.categories
              .where((c) => c.type == _type)
              .toList();
          if (categories.isNotEmpty) {
            _selectedCategory = categories.first;
          }
        }
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _type = _tabController.index == 0
          ? TransactionType.expense
          : TransactionType.income;
      // Select first category of the new type
      final state = context.read<HomeCubit>().state;
      if (state is HomeLoaded) {
        final categories = state.categories
            .where((c) => c.type == _type)
            .toList();
        _selectedCategory = categories.isNotEmpty ? categories.first : null;
      } else {
        _selectedCategory = null;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _onNoteFocusChanged() {
    setState(() {
      _isNoteFieldFocused = _noteFocusNode.hasFocus;
    });
  }

  void _unfocusNote() {
    if (_noteFocusNode.hasFocus) {
      _noteFocusNode.unfocus();
    }
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    const swipeThreshold = 100.0;
    final velocity = details.primaryVelocity ?? 0;

    if (velocity.abs() < swipeThreshold) return;

    if (velocity > 0) {
      // Swipe right -> Expense (index 0)
      if (_tabController.index != 0) {
        _tabController.animateTo(0);
      }
    } else {
      // Swipe left -> Income (index 1)
      if (_tabController.index != 1) {
        _tabController.animateTo(1);
      }
    }
  }

  void _onQuickAmount(double amount) {
    setState(() {
      _expression = _formatNumber(amount);
      _result = amount;
    });
    HapticFeedback.selectionClick();
  }

  void _onKeyPress(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _expression = '0';
          _result = 0;
          break;
        case '⌫':
          if (_expression.length > 1) {
            _expression = _expression.substring(0, _expression.length - 1);
          } else {
            _expression = '0';
          }
          _calculateResult();
          break;
        case '=':
          _calculateResult();
          if (_result > 0) {
            _expression = _formatNumber(_result);
          }
          break;
        case '+':
        case '-':
        case '×':
        case '÷':
          if (_expression != '0' &&
              !'+-×÷'.contains(_expression[_expression.length - 1])) {
            _expression += key;
          } else if (_expression.length > 1 &&
              '+-×÷'.contains(_expression[_expression.length - 1])) {
            _expression =
                _expression.substring(0, _expression.length - 1) + key;
          }
          break;
        case '.':
          final parts = _expression.split(RegExp(r'[+\-×÷]'));
          if (!parts.last.contains('.')) {
            if (_expression == '0') {
              _expression = '0.';
            } else {
              _expression += '.';
            }
          }
          break;
        case '00':
          // Don't add 00 if current number is just 0
          if (_expression != '0') {
            final parts = _expression.split(RegExp(r'[+\-×÷]'));
            // Only add 00 if current number part is not just '0'
            if (parts.last != '0' && parts.last.isNotEmpty) {
              _expression += '00';
              _calculateResult();
            }
          }
          break;
        default:
          if (_expression == '0') {
            _expression = key;
          } else {
            _expression += key;
          }
          _calculateResult();
      }
    });
  }

  void _calculateResult() {
    try {
      String expr = _expression.replaceAll('×', '*').replaceAll('÷', '/');

      if ('+-*/'.contains(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1);
      }

      _result = _evaluateExpression(expr);
    } catch (_) {
      // Keep current result
    }
  }

  double _evaluateExpression(String expression) {
    final tokens = <String>[];
    var currentNumber = '';

    for (var i = 0; i < expression.length; i++) {
      final char = expression[i];
      if ('+-*/'.contains(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      } else {
        currentNumber += char;
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    if (tokens.isEmpty) return 0;

    // Handle * and / first
    final reducedTokens = <String>[];
    var i = 0;
    while (i < tokens.length) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(reducedTokens.removeLast());
        final right = double.parse(tokens[i + 1]);
        final result = tokens[i] == '*' ? left * right : left / right;
        reducedTokens.add(result.toString());
        i += 2;
      } else {
        reducedTokens.add(tokens[i]);
        i++;
      }
    }

    // Handle + and -
    var result = double.parse(reducedTokens[0]);
    i = 1;
    while (i < reducedTokens.length) {
      final op = reducedTokens[i];
      final right = double.parse(reducedTokens[i + 1]);
      result = op == '+' ? result + right : result - right;
      i += 2;
    }

    return result;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _noteFocusNode.removeListener(_onNoteFocusChanged);
    _noteFocusNode.dispose();
    _scrollController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = _type == TransactionType.expense;
    final primaryColor = isExpense ? AppColors.expense : AppColors.income;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: _isNoteFieldFocused,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(theme, primaryColor),

            // Scrollable Content with swipe gesture
            Expanded(
              child: GestureDetector(
                onTap: _unfocusNote,
                onHorizontalDragEnd: _onHorizontalSwipe,
                behavior: HitTestBehavior.opaque,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Toggle Tabs
                      _buildTypeTabs(theme, primaryColor),

                      // Amount Display
                      AmountDisplay(
                        expression: _expression,
                        result: _result,
                        primaryColor: primaryColor,
                        isExpense: isExpense,
                      ),

                      const SizedBox(height: 8),

                      // Category Section
                      _buildCategorySection(theme),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Note Field (always visible, above calculator)
            _buildNoteField(theme, isDark, primaryColor),

            // Spacing between note and calculator
            const SizedBox(height: 12),

            // Calculator Keyboard (hidden when note field is focused)
            if (!_isNoteFieldFocused)
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  final wallets = state is HomeLoaded
                      ? state.wallets
                      : <Wallet>[];
                  return CalculatorKeyboard(
                    primaryColor: primaryColor,
                    onKeyPress: _onKeyPress,
                    onSave: _save,
                    selectedDate: _selectedDate,
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                    },
                    wallets: wallets,
                    selectedWallet: _selectedWallet,
                    onWalletChanged: (wallet) {
                      setState(() => _selectedWallet = wallet);
                    },
                    onQuickAmount: _onQuickAmount,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Close button with subtle background
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.isEditMode
                      ? 'home.edit_transaction'.tr()
                      : 'home.add_transaction'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                // Subtitle showing selected wallet
                if (_selectedWallet != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 12,
                        color: primaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedWallet!.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: primaryColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Placeholder for balance
          const SizedBox(width: 46),
        ],
      ),
    );
  }

  Widget _buildTypeTabs(ThemeData theme, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: _type == TransactionType.expense
                ? AppColors.expenseGradient
                : AppColors.incomeGradient,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward_rounded, size: 18),
                const SizedBox(width: 6),
                Text('home.expense'.tr()),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward_rounded, size: 18),
                const SizedBox(width: 6),
                Text('home.income'.tr()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Category> _getRecentCategories(
    List<Category> categories,
    List<Transaction> transactions,
  ) {
    // Count category usage
    final categoryCount = <String, int>{};
    for (final transaction in transactions) {
      if (transaction.type == _type) {
        categoryCount[transaction.categoryId] =
            (categoryCount[transaction.categoryId] ?? 0) + 1;
      }
    }

    // Filter and sort by usage count
    final recentCategories =
        categories.where((c) => categoryCount.containsKey(c.id)).toList()..sort(
          (a, b) =>
              (categoryCount[b.id] ?? 0).compareTo(categoryCount[a.id] ?? 0),
        );

    // Return top 5 most used categories
    return recentCategories.take(5).toList();
  }

  Widget _buildCategorySection(ThemeData theme) {
    final isExpense = _type == TransactionType.expense;
    final primaryColor = isExpense ? AppColors.expense : AppColors.income;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        final categories = state.categories
            .where((c) => c.type == _type)
            .toList();
        final recentCategories = _getRecentCategories(
          categories,
          state.todayTransactions,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent categories (if any)
            if (recentCategories.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'home.recent'.tr(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentCategories.length,
                  itemBuilder: (context, index) {
                    final category = recentCategories[index];
                    final isSelected = _selectedCategory?.id == category.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _RecentCategoryChip(
                        category: category,
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Category header with validation indicator
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'home.category'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Selected indicator
                  if (_selectedCategory != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 12,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedCategory!.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            CategoryGrid(
              categories: categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteField(ThemeData theme, bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'home.note'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Text field
          TextField(
            controller: _descriptionController,
            focusNode: _noteFocusNode,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Add a note...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.notes_rounded,
                  color: _isNoteFieldFocused
                      ? primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              suffixIcon: _descriptionController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _descriptionController.clear();
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: _isNoteFieldFocused
                  ? (isDark
                        ? primaryColor.withValues(alpha: 0.08)
                        : primaryColor.withValues(alpha: 0.05))
                  : (isDark
                        ? theme.colorScheme.surface.withValues(alpha: 0.8)
                        : theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          )),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: primaryColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
            maxLines: 1,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  void _save() {
    _calculateResult();

    if (_result <= 0) {
      _showError('home.error_amount'.tr());
      return;
    }

    if (_selectedCategory == null) {
      _showError('home.error_category'.tr());
      return;
    }

    if (_selectedWallet == null) {
      _showError('home.error_wallet'.tr());
      return;
    }

    final description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : null;

    if (widget.isEditMode) {
      context.read<HomeCubit>().updateTransaction(
        id: widget.existingTransaction!.id,
        type: _type,
        amount: _result,
        categoryId: _selectedCategory!.id,
        walletId: _selectedWallet!.id,
        date: _selectedDate,
        description: description,
      );
    } else {
      context.read<HomeCubit>().addTransaction(
        type: _type,
        amount: _result,
        categoryId: _selectedCategory!.id,
        walletId: _selectedWallet!.id,
        date: _selectedDate,
        description: description,
      );
    }

    HapticFeedback.heavyImpact();
    context.pop();
  }

  void _showError(String message) {
    HapticFeedback.vibrate();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Error Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: isDark
                  ? theme.colorScheme.surface
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.all(28),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with gradient background and shadow
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.shade400.withValues(alpha: 0.2),
                          Colors.red.shade600.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.priority_high_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    'common.error'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // Button with gradient
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'common.close'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecentCategoryChip extends StatefulWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecentCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RecentCategoryChip> createState() => _RecentCategoryChipState();
}

class _RecentCategoryChipState extends State<_RecentCategoryChip> {
  bool _isPressed = false;

  Color _getCategoryColor() {
    if (widget.category.color != null) {
      try {
        return Color(
          int.parse(widget.category.color!.replaceFirst('#', '0xFF')),
        );
      } catch (_) {}
    }
    return Colors.grey;
  }

  IconData _getCategoryIcon() {
    return IconUtils.getIconData(widget.category.icon ?? 'category');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getCategoryColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.8)],
                  )
                : null,
            color: widget.isSelected
                ? null
                : isDark
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : color.withValues(alpha: 0.3),
              width: widget.isSelected ? 0 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(),
                size: 16,
                color: widget.isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
