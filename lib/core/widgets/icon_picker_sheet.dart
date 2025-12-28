import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

/// Icon category for wallet/category icon selection
class IconCategory {
  final String nameKey;
  final IconData icon;
  final List<IconData> icons;

  const IconCategory({
    required this.nameKey,
    required this.icon,
    required this.icons,
  });
}

/// All available icon categories
final List<IconCategory> iconCategories = [
  IconCategory(
    nameKey: 'wallet.icon_cat_money',
    icon: Icons.attach_money_rounded,
    icons: [
      Icons.account_balance_wallet_rounded,
      Icons.wallet_rounded,
      Icons.payments_rounded,
      Icons.money_rounded,
      Icons.attach_money_rounded,
      Icons.currency_exchange_rounded,
      Icons.savings_rounded,
      Icons.monetization_on_rounded,
      Icons.paid_rounded,
      Icons.price_check_rounded,
      Icons.request_quote_rounded,
      Icons.receipt_long_rounded,
      Icons.toll_rounded,
      Icons.local_atm_rounded,
      Icons.account_balance_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_cards',
    icon: Icons.credit_card_rounded,
    icons: [
      Icons.credit_card_rounded,
      Icons.credit_score_rounded,
      Icons.card_giftcard_rounded,
      Icons.card_membership_rounded,
      Icons.card_travel_rounded,
      Icons.payment_rounded,
      Icons.contactless_rounded,
      Icons.add_card_rounded,
      Icons.credit_card_off_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_bank',
    icon: Icons.account_balance_rounded,
    icons: [
      Icons.account_balance_rounded,
      Icons.business_rounded,
      Icons.corporate_fare_rounded,
      Icons.domain_rounded,
      Icons.apartment_rounded,
      Icons.home_work_rounded,
      Icons.assured_workload_rounded,
      Icons.real_estate_agent_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_investment',
    icon: Icons.trending_up_rounded,
    icons: [
      Icons.trending_up_rounded,
      Icons.show_chart_rounded,
      Icons.candlestick_chart_rounded,
      Icons.bar_chart_rounded,
      Icons.ssid_chart_rounded,
      Icons.stacked_line_chart_rounded,
      Icons.analytics_rounded,
      Icons.insights_rounded,
      Icons.auto_graph_rounded,
      Icons.query_stats_rounded,
      Icons.diamond_rounded,
      Icons.workspace_premium_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_crypto',
    icon: Icons.currency_bitcoin_rounded,
    icons: [
      Icons.currency_bitcoin_rounded,
      Icons.token_rounded,
      Icons.generating_tokens_rounded,
      Icons.hub_rounded,
      Icons.blur_on_rounded,
      Icons.all_inclusive_rounded,
      Icons.change_circle_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_shopping',
    icon: Icons.shopping_bag_rounded,
    icons: [
      Icons.shopping_bag_rounded,
      Icons.shopping_cart_rounded,
      Icons.shopping_basket_rounded,
      Icons.store_rounded,
      Icons.storefront_rounded,
      Icons.local_mall_rounded,
      Icons.local_grocery_store_rounded,
      Icons.add_shopping_cart_rounded,
      Icons.shop_rounded,
      Icons.redeem_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_travel',
    icon: Icons.flight_rounded,
    icons: [
      Icons.flight_rounded,
      Icons.directions_car_rounded,
      Icons.directions_bus_rounded,
      Icons.train_rounded,
      Icons.directions_boat_rounded,
      Icons.local_taxi_rounded,
      Icons.two_wheeler_rounded,
      Icons.electric_car_rounded,
      Icons.luggage_rounded,
      Icons.hotel_rounded,
      Icons.beach_access_rounded,
      Icons.hiking_rounded,
      Icons.terrain_rounded,
      Icons.map_rounded,
      Icons.explore_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_food',
    icon: Icons.restaurant_rounded,
    icons: [
      Icons.restaurant_rounded,
      Icons.fastfood_rounded,
      Icons.local_dining_rounded,
      Icons.local_cafe_rounded,
      Icons.local_bar_rounded,
      Icons.local_pizza_rounded,
      Icons.coffee_rounded,
      Icons.bakery_dining_rounded,
      Icons.lunch_dining_rounded,
      Icons.dinner_dining_rounded,
      Icons.ramen_dining_rounded,
      Icons.icecream_rounded,
      Icons.cake_rounded,
      Icons.wine_bar_rounded,
      Icons.sports_bar_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_health',
    icon: Icons.favorite_rounded,
    icons: [
      Icons.favorite_rounded,
      Icons.health_and_safety_rounded,
      Icons.medical_services_rounded,
      Icons.local_hospital_rounded,
      Icons.medication_rounded,
      Icons.healing_rounded,
      Icons.spa_rounded,
      Icons.fitness_center_rounded,
      Icons.sports_gymnastics_rounded,
      Icons.self_improvement_rounded,
      Icons.psychology_rounded,
      Icons.vaccines_rounded,
      Icons.monitor_heart_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_home',
    icon: Icons.home_rounded,
    icons: [
      Icons.home_rounded,
      Icons.house_rounded,
      Icons.cottage_rounded,
      Icons.villa_rounded,
      Icons.cabin_rounded,
      Icons.bed_rounded,
      Icons.chair_rounded,
      Icons.weekend_rounded,
      Icons.bathtub_rounded,
      Icons.kitchen_rounded,
      Icons.microwave_rounded,
      Icons.blender_rounded,
      Icons.local_laundry_service_rounded,
      Icons.iron_rounded,
      Icons.lightbulb_rounded,
      Icons.bolt_rounded,
      Icons.water_drop_rounded,
      Icons.local_fire_department_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_tech',
    icon: Icons.devices_rounded,
    icons: [
      Icons.devices_rounded,
      Icons.smartphone_rounded,
      Icons.phone_android_rounded,
      Icons.phone_iphone_rounded,
      Icons.tablet_rounded,
      Icons.laptop_rounded,
      Icons.computer_rounded,
      Icons.desktop_windows_rounded,
      Icons.tv_rounded,
      Icons.monitor_rounded,
      Icons.watch_rounded,
      Icons.headphones_rounded,
      Icons.speaker_rounded,
      Icons.camera_alt_rounded,
      Icons.videocam_rounded,
      Icons.gamepad_rounded,
      Icons.mouse_rounded,
      Icons.keyboard_rounded,
      Icons.memory_rounded,
      Icons.usb_rounded,
      Icons.wifi_rounded,
      Icons.bluetooth_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_education',
    icon: Icons.school_rounded,
    icons: [
      Icons.school_rounded,
      Icons.menu_book_rounded,
      Icons.auto_stories_rounded,
      Icons.library_books_rounded,
      Icons.book_rounded,
      Icons.chrome_reader_mode_rounded,
      Icons.class_rounded,
      Icons.science_rounded,
      Icons.psychology_rounded,
      Icons.lightbulb_rounded,
      Icons.emoji_objects_rounded,
      Icons.architecture_rounded,
      Icons.engineering_rounded,
      Icons.biotech_rounded,
      Icons.calculate_rounded,
      Icons.functions_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_entertainment',
    icon: Icons.movie_rounded,
    icons: [
      Icons.movie_rounded,
      Icons.theaters_rounded,
      Icons.live_tv_rounded,
      Icons.music_note_rounded,
      Icons.library_music_rounded,
      Icons.headphones_rounded,
      Icons.piano_rounded,
      Icons.sports_esports_rounded,
      Icons.sports_soccer_rounded,
      Icons.sports_basketball_rounded,
      Icons.sports_tennis_rounded,
      Icons.sports_golf_rounded,
      Icons.pool_rounded,
      Icons.casino_rounded,
      Icons.celebration_rounded,
      Icons.festival_rounded,
      Icons.nightlife_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_people',
    icon: Icons.people_rounded,
    icons: [
      Icons.people_rounded,
      Icons.person_rounded,
      Icons.group_rounded,
      Icons.groups_rounded,
      Icons.family_restroom_rounded,
      Icons.child_care_rounded,
      Icons.child_friendly_rounded,
      Icons.elderly_rounded,
      Icons.pets_rounded,
      Icons.cruelty_free_rounded,
      Icons.volunteer_activism_rounded,
      Icons.handshake_rounded,
      Icons.diversity_1_rounded,
      Icons.diversity_2_rounded,
      Icons.diversity_3_rounded,
    ],
  ),
  IconCategory(
    nameKey: 'wallet.icon_cat_other',
    icon: Icons.category_rounded,
    icons: [
      Icons.category_rounded,
      Icons.label_rounded,
      Icons.bookmark_rounded,
      Icons.star_rounded,
      Icons.flag_rounded,
      Icons.local_offer_rounded,
      Icons.loyalty_rounded,
      Icons.verified_rounded,
      Icons.grade_rounded,
      Icons.emoji_events_rounded,
      Icons.military_tech_rounded,
      Icons.shield_rounded,
      Icons.security_rounded,
      Icons.lock_rounded,
      Icons.key_rounded,
      Icons.vpn_key_rounded,
      Icons.pin_rounded,
      Icons.numbers_rounded,
      Icons.tag_rounded,
      Icons.qr_code_rounded,
      Icons.fingerprint_rounded,
      Icons.face_rounded,
    ],
  ),
];

/// Show icon picker bottom sheet and return selected icon
Future<IconData?> showIconPicker({
  required BuildContext context,
  required IconData selectedIcon,
  required Color accentColor,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showModalBottomSheet<IconData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => IconPickerSheet(
      selectedIcon: selectedIcon,
      accentColor: accentColor,
      isDark: isDark,
      theme: theme,
    ),
  );
}

/// Custom Icon Picker Bottom Sheet with categories
class IconPickerSheet extends StatefulWidget {
  final IconData selectedIcon;
  final Color accentColor;
  final bool isDark;
  final ThemeData theme;

  const IconPickerSheet({
    super.key,
    required this.selectedIcon,
    required this.accentColor,
    required this.isDark,
    required this.theme,
  });

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  int _selectedCategoryIndex = 0;
  late IconData _currentIcon;
  final ScrollController _categoryScrollController = ScrollController();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.selectedIcon;

    // Find which category contains the selected icon
    for (int i = 0; i < iconCategories.length; i++) {
      if (iconCategories[i].icons.contains(widget.selectedIcon)) {
        _selectedCategoryIndex = i;
        break;
      }
    }

    _pageController = PageController(initialPage: _selectedCategoryIndex);

    // Auto-scroll to selected category chip after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedCategory();
    });
  }

  void _scrollToSelectedCategory() {
    if (!_categoryScrollController.hasClients) return;

    final targetPosition = _selectedCategoryIndex * 110.0;
    final maxScroll = _categoryScrollController.position.maxScrollExtent;
    final scrollTo = (targetPosition - 100).clamp(0.0, maxScroll);

    _categoryScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedCategoryIndex = index);
    _scrollToSelectedCategory();
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isDark = widget.isDark;
    final accentColor = widget.accentColor;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Gradient Header
          _buildHeader(theme, accentColor),

          const SizedBox(height: 20),

          // Category chips with scroll indicator
          _buildCategoryChips(theme, isDark, accentColor),

          const SizedBox(height: 16),

          // Icon grid with PageView for swipe support
          _buildIconGrid(theme, isDark, accentColor),

          // Page indicator dots
          _buildPageIndicator(theme, accentColor),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color accentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.85),
            accentColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Preview Icon with glow
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                _currentIcon,
                key: ValueKey(_currentIcon),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'wallet.type_icon'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${iconCategories.fold<int>(0, (sum, cat) => sum + cat.icons.length)} icons',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Select button
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context, _currentIcon);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'common.ok'.tr(),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, bool isDark, Color accentColor) {
    return SizedBox(
      height: 50,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.transparent,
            isDark ? const Color(0xFF1A1A2E) : Colors.white,
            isDark ? const Color(0xFF1A1A2E) : Colors.white,
            Colors.transparent,
          ],
          stops: const [0, 0.02, 0.98, 1],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          controller: _categoryScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: iconCategories.length,
          itemBuilder: (context, index) {
            final category = iconCategories[index];
            final isSelected = index == _selectedCategoryIndex;

            return Padding(
              padding: EdgeInsets.only(
                  right: index < iconCategories.length - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                            ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5)
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? null
                        : Border.all(
                            color:
                                theme.colorScheme.outline.withValues(alpha: 0.1),
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: isSelected ? 20 : 18,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.nameKey.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                          letterSpacing: isSelected ? 0.2 : 0,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${category.icons.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconGrid(ThemeData theme, bool isDark, Color accentColor) {
    return Flexible(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: iconCategories.length,
        itemBuilder: (context, categoryIndex) {
          final category = iconCategories[categoryIndex];
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: category.icons.length,
            itemBuilder: (context, index) {
              final icon = category.icons[index];
              final isSelected = icon == _currentIcon;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _currentIcon = icon);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              accentColor,
                              accentColor.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : isDark
                            ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4)
                            : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.5)
                          : theme.colorScheme.outline.withValues(alpha: 0.08),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Icon
                      Icon(
                        icon,
                        size: 28,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      // Check indicator for selected
                      if (isSelected)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 10,
                              color: accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme, Color accentColor) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          iconCategories.length,
          (index) {
            final isActive = index == _selectedCategoryIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isActive
                    ? null
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
