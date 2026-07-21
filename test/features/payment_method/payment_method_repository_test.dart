import 'package:flutter_test/flutter_test.dart';
import 'package:paysa/core/app_exception.dart';
import 'package:paysa/features/payment_method/data/datasources/payment_method_local_datasource.dart';
import 'package:paysa/features/payment_method/data/models/payment_method_record.dart';
import 'package:paysa/features/payment_method/data/repositories/payment_method_repository_impl.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method_defaults.dart';
import 'package:paysa/features/payment_method/domain/entities/payment_method_type.dart';
import 'package:paysa/features/payment_method/domain/repositories/payment_method_repository.dart';

final class InMemoryPaymentMethodDataSource implements PaymentMethodLocalDataSource {
  final _records = <int, PaymentMethodRecord>{};
  int _nextId = 1;

  @override
  Future<PaymentMethodRecord> put(PaymentMethodRecord record) async {
    if (record.id == 0) record.id = _nextId++;
    if (record.uuid.isEmpty) record.uuid = 'pm-${record.id}';
    _records[record.id] = record;
    return record;
  }

  @override Future<PaymentMethodRecord?> getById(int id) async => _records[id];

  @override Future<List<PaymentMethodRecord>> getAll() async => _records.values.toList();

  @override Stream<List<PaymentMethodRecord>> watchAll() async* { yield _records.values.toList(); }

  @override Future<void> delete(int id) async { _records.remove(id); }
}

final _now = DateTime.now();

void main() {
  late PaymentMethodRepository repo;

  setUp(() {
    repo = PaymentMethodRepositoryImpl(InMemoryPaymentMethodDataSource());
  });

  group('initializeDefaults', () {
    test('creates 11 system presets', () async {
      await repo.initializeDefaults();
      final all = await repo.getAll();
      expect(all.length, 11);
      expect(all.where((m) => m.isBuiltIn).length, 11);
    });

    test('idempotent — does not duplicate on second call', () async {
      await repo.initializeDefaults();
      await repo.initializeDefaults();
      final all = await repo.getAll();
      expect(all.length, 11);
    });
  });

  group('create', () {
    test('creates custom method', () async {
      final m = await repo.create(PaymentMethod(
        name: 'My Wallet', type: PaymentMethodType.digitalWallet,
        createdAt: _now, updatedAt: _now,
      ));
      expect(m.id, greaterThan(0));
      expect(m.isBuiltIn, false);
    });

    test('rejects duplicate name', () async {
      await repo.create(PaymentMethod(name: 'Test', createdAt: _now, updatedAt: _now));
      expect(() => repo.create(PaymentMethod(name: 'Test', createdAt: _now, updatedAt: _now)),
          throwsA(isA<AppException>()));
    });

    test('rejects empty name', () async {
      expect(() => repo.create(PaymentMethod(name: '', createdAt: _now, updatedAt: _now)),
          throwsA(isA<AppException>()));
    });
  });

  group('update', () {
    test('updates name and increments version', () async {
      final m = await repo.create(PaymentMethod(name: 'Old', createdAt: _now, updatedAt: _now));
      final updated = await repo.update(m.copyWith(name: 'New'));
      expect(updated.name, 'New');
      expect(updated.version, 2);
    });

    test('blocks rename of built-in', () async {
      await repo.initializeDefaults();
      final all = await repo.getAll();
      expect(() => repo.update(all.first.copyWith(name: 'Renamed')),
          throwsA(isA<AppException>()));
    });
  });

  group('enable / disable / toggleFavorite', () {
    test('toggle favorite', () async {
      final m = await repo.create(PaymentMethod(name: 'T', createdAt: _now, updatedAt: _now));
      await repo.toggleFavorite(m.id);
      final updated = await repo.getById(m.id);
      expect(updated?.isFavorite, true);
    });

    test('disable custom method', () async {
      final m = await repo.create(PaymentMethod(name: 'T', createdAt: _now, updatedAt: _now));
      await repo.disable(m.id);
      expect((await repo.getById(m.id))?.isEnabled, false);
    });

    test('blocks disable of built-in', () async {
      await repo.initializeDefaults();
      final all = await repo.getAll();
      expect(() => repo.disable(all.first.id), throwsA(isA<AppException>()));
    });
  });

  group('archive / restore / delete', () {
    test('archive and restore', () async {
      final m = await repo.create(PaymentMethod(name: 'T', createdAt: _now, updatedAt: _now));
      await repo.archive(m.id);
      expect((await repo.getById(m.id))?.isEnabled, false);
      await repo.restore(m.id);
      expect((await repo.getById(m.id))?.isEnabled, true);
    });

    test('blocks delete of built-in', () async {
      await repo.initializeDefaults();
      expect(() => repo.delete(1), throwsA(isA<AppException>()));
    });

    test('soft deletes custom method', () async {
      final m = await repo.create(PaymentMethod(name: 'T', createdAt: _now, updatedAt: _now));
      await repo.delete(m.id);
      final all = await repo.getAll();
      expect(all.where((x) => x.id == m.id), isEmpty);
    });
  });

  group('search / filter', () {
    test('search by name', () async {
      await repo.create(PaymentMethod(name: 'bKash', createdAt: _now, updatedAt: _now));
      await repo.create(PaymentMethod(name: 'Bank Account', createdAt: _now, updatedAt: _now));
      final results = await repo.getAll(searchQuery: 'bkash');
      expect(results.length, 1);
    });

    test('enabled only', () async {
      final m = await repo.create(PaymentMethod(name: 'A', createdAt: _now, updatedAt: _now));
      await repo.disable(m.id);
      final enabled = await repo.getEnabled();
      expect(enabled.where((x) => x.id == m.id), isEmpty);
    });

    test('sorted by sortOrder', () async {
      await repo.create(PaymentMethod(name: 'Z', createdAt: _now, updatedAt: _now));
      await repo.create(PaymentMethod(name: 'A', createdAt: _now, updatedAt: _now));
      final all = await repo.getAll();
      expect(all.first.sortOrder, 0);
      expect(all.last.sortOrder, 1);
    });
  });

  group('reorder', () {
    test('updates sort order', () async {
      await repo.initializeDefaults();
      await repo.reorder(1, 99);
      final updated = await repo.getById(1);
      expect(updated?.sortOrder, 99);
    });
  });
}
