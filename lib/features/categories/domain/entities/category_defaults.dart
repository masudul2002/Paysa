import 'category.dart';

final class CategoryDefaults {
  const CategoryDefaults._();

  static const defaultCurrency = 'USD';

  static String iconFor(CategoryType type) => switch (type) {
        CategoryType.income => 'income',
        CategoryType.expense => 'expense',
      };

  static int colorFor(CategoryType type) => switch (type) {
        CategoryType.income => 0xFF059669,
        CategoryType.expense => 0xFFDC2626,
      };

  static String defaultNameFor(CategoryGroup group) => group.label;

  static String iconForGroup(CategoryGroup group) => switch (group) {
        CategoryGroup.housing => 'home',
        CategoryGroup.transportation => 'directions_car',
        CategoryGroup.food => 'restaurant',
        CategoryGroup.utilities => 'bolt',
        CategoryGroup.entertainment => 'movie',
        CategoryGroup.shopping => 'shopping_bag',
        CategoryGroup.health => 'favorite',
        CategoryGroup.education => 'school',
        CategoryGroup.salary => 'payments',
        CategoryGroup.freelance => 'work',
        CategoryGroup.investment => 'trending_up',
        CategoryGroup.business => 'business',
        CategoryGroup.other => 'category',
      };

  static int colorForGroup(CategoryGroup group) => switch (group) {
        CategoryGroup.housing => 0xFF8B5CF6,
        CategoryGroup.transportation => 0xFFF59E0B,
        CategoryGroup.food => 0xFFEF4444,
        CategoryGroup.utilities => 0xFF3B82F6,
        CategoryGroup.entertainment => 0xFFEC4899,
        CategoryGroup.shopping => 0xFF14B8A6,
        CategoryGroup.health => 0xFF10B981,
        CategoryGroup.education => 0xFF6366F1,
        CategoryGroup.salary => 0xFF22C55E,
        CategoryGroup.freelance => 0xFF8B5CF6,
        CategoryGroup.investment => 0xFFF97316,
        CategoryGroup.business => 0xFF0EA5E9,
        CategoryGroup.other => 0xFF6B7280,
      };
}
