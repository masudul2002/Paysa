import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/features/people/domain/entities/person.dart';
import 'package:paysa/features/people/domain/entities/person_defaults.dart';

final _now = DateTime.now();

void main() {
  group('Person entity', () {
    test('default constructor values', () {
      final p = Person(id: 0, name: 'Test', createdAt: _now, updatedAt: _now);
      expect(p.id, 0);
      expect(p.name, 'Test');
      expect(p.type, PersonType.other);
      expect(p.phone, isNull);
      expect(p.email, isNull);
      expect(p.isFavorite, false);
      expect(p.isActive, true);
      expect(p.isArchived, false);
      expect(p.isDeleted, false);
    });

    test('archived person', () {
      final p = Person(id: 0, name: 'Test', status: PersonStatus.archived, createdAt: _now, updatedAt: _now);
      expect(p.isArchived, true);
      expect(p.isActive, false);
    });

    test('deleted person', () {
      final p = Person(id: 0, name: 'Test', createdAt: _now, updatedAt: _now, deletedAt: _now);
      expect(p.isDeleted, true);
    });

    test('copyWith changes specified fields', () {
      final p = Person(id: 1, name: 'Alice', type: PersonType.friend, createdAt: _now, updatedAt: _now);
      final copy = p.copyWith(name: 'Bob', type: PersonType.customer);
      expect(copy.name, 'Bob');
      expect(copy.type, PersonType.customer);
      expect(copy.id, 1); // unchanged
    });

    test('all 7 person types have labels', () {
      for (final t in PersonType.values) {
        expect(t.label.isNotEmpty, true);
      }
    });

    test('person type count', () {
      expect(PersonType.values.length, 7);
    });
  });

  group('PersonDefaults', () {
    test('default currency is USD', () {
      expect(PersonDefaults.defaultCurrency, 'USD');
    });

    test('default values for each type', () {
      for (final t in PersonType.values) {
        expect(PersonDefaults.iconFor(t), isNotEmpty);
        expect(PersonDefaults.colorFor(t), greaterThan(0));
      }
    });
  });

  group('OpeningBalanceDirection', () {
    test('all directions have labels', () {
      for (final d in OpeningBalanceDirection.values) {
        expect(d.label.isNotEmpty, true);
      }
    });

    test('none direction label', () {
      expect(OpeningBalanceDirection.none.label, 'None');
    });

    test('give direction label', () {
      expect(OpeningBalanceDirection.give.label, 'They owe me');
    });

    test('receive direction label', () {
      expect(OpeningBalanceDirection.receive.label, 'I owe them');
    });
  });

  group('PersonStatus', () {
    test('active and archived exist', () {
      expect(PersonStatus.values.length, 2);
      expect(PersonStatus.active.label, 'Active');
      expect(PersonStatus.archived.label, 'Archived');
    });
  });
}
