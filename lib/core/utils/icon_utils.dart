import 'package:flutter/material.dart';

class IconUtils {
  static final Map<String, IconData> _iconMap = {
    // Food & Drink
    'restaurant': Icons.restaurant_rounded,
    'fastfood': Icons.fastfood_rounded,
    'local_cafe': Icons.local_cafe_rounded,
    'local_bar': Icons.local_bar_rounded,
    'local_pizza': Icons.local_pizza_rounded,
    'bakery_dining': Icons.bakery_dining_rounded,

    // Transport
    'directions_car': Icons.directions_car_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'flight': Icons.flight_rounded,
    'train': Icons.train_rounded,
    'motorcycle': Icons.two_wheeler_rounded,
    'local_gas_station': Icons.local_gas_station_rounded,

    // Shopping
    'shopping_bag': Icons.shopping_bag_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'storefront': Icons.storefront_rounded,
    'local_mall': Icons.local_mall_rounded,

    // Entertainment
    'movie': Icons.movie_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'music_note': Icons.music_note_rounded,
    'theater_comedy': Icons.theater_comedy_rounded,
    'celebration': Icons.celebration_rounded,

    // Bills & Utilities
    'receipt': Icons.receipt_rounded,
    'receipt_long': Icons.receipt_long_rounded,
    'electric_bolt': Icons.electric_bolt_rounded,
    'water_drop': Icons.water_drop_rounded,
    'wifi': Icons.wifi_rounded,
    'phone': Icons.phone_rounded,
    'home': Icons.home_rounded,

    // Health
    'medical_services': Icons.medical_services_rounded,
    'local_hospital': Icons.local_hospital_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'spa': Icons.spa_rounded,

    // Income
    'payments': Icons.payments_rounded,
    'work': Icons.work_rounded,
    'trending_up': Icons.trending_up_rounded,
    'account_balance': Icons.account_balance_rounded,
    'savings': Icons.savings_rounded,

    // Gifts
    'card_giftcard': Icons.card_giftcard_rounded,
    'redeem': Icons.redeem_rounded,

    // Education
    'school': Icons.school_rounded,
    'menu_book': Icons.menu_book_rounded,

    // Pets
    'pets': Icons.pets_rounded,

    // Family
    'family_restroom': Icons.family_restroom_rounded,
    'child_care': Icons.child_care_rounded,

    // Travel
    'luggage': Icons.luggage_rounded,
    'beach_access': Icons.beach_access_rounded,
    'hotel': Icons.hotel_rounded,

    // Default
    'category': Icons.category_rounded,
    'more_horiz': Icons.more_horiz_rounded,
  };

  static IconData getIconData(String iconName) {
    return _iconMap[iconName] ?? Icons.category_rounded;
  }

  static List<MapEntry<String, IconData>> getAllIcons() {
    return _iconMap.entries.toList();
  }

  static List<String> getIconNames() {
    return _iconMap.keys.toList();
  }
}
