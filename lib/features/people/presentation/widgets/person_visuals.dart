import 'package:flutter/material.dart';

import '../../domain/entities/person.dart';
import '../../domain/entities/person_defaults.dart';

Color personColorFromValue(int colorValue) => Color(colorValue);

IconData personIconFromKey(String key) {
  return switch (key) {
    'customer' => Icons.person_outlined,
    'supplier' => Icons.inventory_2_outlined,
    'friend' => Icons.favorite_outlined,
    'family' => Icons.family_restroom_outlined,
    'employee' => Icons.badge_outlined,
    'business_partner' => Icons.handshake_outlined,
    'person' => Icons.person_outlined,
    _ => Icons.person_outlined,
  };
}

IconData personTypeIcon(PersonType type) =>
    personIconFromKey(PersonDefaults.iconFor(type));

Color personTypeColor(PersonType type) =>
    personColorFromValue(PersonDefaults.colorFor(type));
