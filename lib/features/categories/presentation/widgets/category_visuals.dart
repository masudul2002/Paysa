import 'package:flutter/material.dart';

Color categoryColorFromValue(int colorValue) {
  return Color(colorValue);
}

IconData categoryIconFromKey(String key) {
  return switch (key) {
    'home' => Icons.home_outlined,
    'directions_car' => Icons.directions_car_outlined,
    'restaurant' => Icons.restaurant_outlined,
    'bolt' => Icons.bolt_outlined,
    'movie' => Icons.movie_outlined,
    'shopping_bag' => Icons.shopping_bag_outlined,
    'favorite' => Icons.favorite_outlined,
    'school' => Icons.school_outlined,
    'payments' => Icons.payments_outlined,
    'work' => Icons.work_outlined,
    'trending_up' => Icons.trending_up_outlined,
    'business' => Icons.business_outlined,
    'income' => Icons.arrow_circle_up_outlined,
    'expense' => Icons.arrow_circle_down_outlined,
    'category' => Icons.category_outlined,
    _ => Icons.category_outlined,
  };
}
