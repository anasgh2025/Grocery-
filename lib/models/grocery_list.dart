import 'package:flutter/material.dart';

/// Model for a grocery list
class GroceryList {
  final String id;
  final String name;
  final String items;
  final double progress;
  final String time;
  final IconData icon;
  final List<dynamic>? listItems;

  GroceryList({
    required this.id,
    required this.name,
    required this.items,
    required this.progress,
    required this.time,
    required this.icon,
    this.listItems,
  });

  /// Create a GroceryList from JSON
  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: json['items'] as String,
      progress: (json['progress'] as num).toDouble(),
      time: json['time'] as String,
      icon: _getIconFromString(json['icon'] as String?),
      listItems: json['listItems'] != null ? List<dynamic>.from(json['listItems'] as List) : null,
    );
  }

  /// Convert GroceryList to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items,
      'progress': progress,
      'time': time,
      'icon': _getIconString(icon),
      if (listItems != null) 'listItems': listItems,
    };
  }

  /// Get IconData from string name
  static IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'celebration':
        return Icons.celebration_outlined;
      case 'breakfast':
        return Icons.breakfast_dining_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'apple':
        return Icons.apple_outlined;
      case 'inventory':
        return Icons.inventory_2_outlined;
      case 'child_care':
        return Icons.child_care_outlined;
      case 'pets':
        return Icons.pets_outlined;
      default:
        return Icons.list_outlined;
    }
  }

  /// Get icon string from IconData
  static String _getIconString(IconData icon) {
    if (icon == Icons.shopping_cart_outlined) return 'shopping_cart';
    if (icon == Icons.celebration_outlined) return 'celebration';
    if (icon == Icons.breakfast_dining_outlined) return 'breakfast';
    if (icon == Icons.cleaning_services_outlined) return 'cleaning';
    if (icon == Icons.apple_outlined) return 'apple';
    if (icon == Icons.inventory_2_outlined) return 'inventory';
    if (icon == Icons.child_care_outlined) return 'child_care';
    if (icon == Icons.pets_outlined) return 'pets';
    return 'list';
  }
}
