import 'person.dart';

final class PersonDefaults {
  const PersonDefaults._();

  static const defaultCurrency = 'USD';

  static String iconFor(PersonType type) => switch (type) {
        PersonType.customer => 'customer',
        PersonType.supplier => 'supplier',
        PersonType.friend => 'friend',
        PersonType.family => 'family',
        PersonType.employee => 'employee',
        PersonType.businessPartner => 'business_partner',
        PersonType.other => 'person',
      };

  static int colorFor(PersonType type) => switch (type) {
        PersonType.customer => 0xFF059669,
        PersonType.supplier => 0xFFD97706,
        PersonType.friend => 0xFF7C3AED,
        PersonType.family => 0xFFDC2626,
        PersonType.employee => 0xFF2563EB,
        PersonType.businessPartner => 0xFF0891B2,
        PersonType.other => 0xFF6B7280,
      };
}
