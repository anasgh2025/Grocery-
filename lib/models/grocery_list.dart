import 'package:flutter/material.dart';

/// Model for a grocery list
class GroceryList {
  final String id;
  final String name;
  final String items;
  final double progress;
  final int priority;       // 0 = Normal, 1 = Urgent
  final String time;
  final String? category;
  final IconData icon;
  final List<dynamic>? listItems;

  GroceryList({
    required this.id,
    required this.name,
    required this.items,
    required this.progress,
    this.priority = 0,
    required this.time,
    this.category,
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
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      time: json['time'] as String,
      category: (json['category'] as String?) ?? (json['type'] as String?),
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
      'priority': priority,
      'time': time,
      if (category != null) 'category': category,
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
