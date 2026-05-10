import 'package:flutter/material.dart';

class CategoryUiHelpers {
  static final Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'shopping_bag': Icons.shopping_bag,
    'favorite': Icons.favorite,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'medical_services': Icons.medical_services,
    'flight': Icons.flight,
    'movie': Icons.movie,
    'receipt': Icons.receipt,
    'local_grocery_store': Icons.local_grocery_store,
    'payments': Icons.payments,
    'trending_up': Icons.trending_up,
  };

  static IconData parseIcon(String? iconName) {
    return _iconMap[iconName] ?? Icons.category;
  }

  static Color parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
