import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCode': icon.codePoint,
    'colorValue': color.value,
    'isCustom': isCustom,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
    color: Color(json['colorValue']),
    isCustom: json['isCustom'] ?? false,
  );
}

class CategoryManager {
  static const String _storageKey = 'custom_categories';
  
  // Default categories
  static final List<Category> _defaultCategories = [
    Category(
      id: 'general',
      name: 'General',
      icon: Icons.public,
      color: Colors.blue,
    ),
    Category(
      id: 'business',
      name: 'Business',
      icon: Icons.business,
      color: Colors.green,
    ),
    Category(
      id: 'technology',
      name: 'Technology',
      icon: Icons.computer,
      color: Colors.purple,
    ),
    Category(
      id: 'health',
      name: 'Health',
      icon: Icons.health_and_safety,
      color: Colors.red,
    ),
    Category(
      id: 'science',
      name: 'Science',
      icon: Icons.science,
      color: Colors.teal,
    ),
    Category(
      id: 'sports',
      name: 'Sports',
      icon: Icons.sports_soccer,
      color: Colors.orange,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.pink,
    ),
  ];

  // Available icons for custom categories
  static const List<IconData> availableIcons = [
    Icons.favorite,
    Icons.star,
    Icons.local_fire_department,
    Icons.trending_up,
    Icons.language,
    Icons.travel_explore,
    Icons.restaurant,
    Icons.music_note,
    Icons.camera_alt,
    Icons.book,
    Icons.school,
    Icons.work,
    Icons.home,
    Icons.pets,
    Icons.directions_car,
    Icons.flight,
    Icons.shopping_cart,
    Icons.account_balance,
    Icons.gavel,
    Icons.security,
  ];

  // Available colors for custom categories
  static const List<Color> availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Get all categories (default + custom)
  static Future<List<Category>> getAllCategories() async {
    final customCategories = await getCustomCategories();
    return [..._defaultCategories, ...customCategories];
  }

  // Get only custom categories
  static Future<List<Category>> getCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList(_storageKey) ?? [];
    
    return categoriesJson
        .map((json) => Category.fromJson(jsonDecode(json)))
        .toList();
  }

  // Save custom category
  static Future<void> saveCustomCategory(Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final existingCategories = await getCustomCategories();
    
    // Add new category
    existingCategories.add(category.copyWith(isCustom: true));
    
    // Save to preferences
    final categoriesJson = existingCategories
        .map((cat) => jsonEncode(cat.toJson()))
        .toList();
    
    await prefs.setStringList(_storageKey, categoriesJson);
  }

  // Delete custom category
  static Future<void> deleteCustomCategory(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingCategories = await getCustomCategories();
    
    // Remove category
    existingCategories.removeWhere((cat) => cat.id == categoryId);
    
    // Save updated list
    final categoriesJson = existingCategories
        .map((cat) => jsonEncode(cat.toJson()))
        .toList();
    
    await prefs.setStringList(_storageKey, categoriesJson);
  }

  // Generate unique ID for new category
  static String generateCategoryId(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return 'custom_${cleanName}_$timestamp';
  }
}

// Extension to add copyWith method to Category
extension CategoryExtension on Category {
  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isCustom,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
