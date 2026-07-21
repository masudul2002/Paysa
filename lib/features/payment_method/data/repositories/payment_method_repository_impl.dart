import 'package:paysa/core/app_exception.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_method_defaults.dart';
import '../../domain/repositories/payment_method_repository.dart';
import '../datasources/payment_method_local_datasource.dart';
import '../models/payment_method_record.dart';

final class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  const PaymentMethodRepositoryImpl(this._dataSource);

  final PaymentMethodLocalDataSource _dataSource;

  @override
  Future<void> initializeDefaults() async {
    final existing = await _dataSource.getAll();
    if (existing.isNotEmpty) return; // already seeded

    final now = DateTime.now();
    for (final preset in PaymentMethodDefaults.systemPresets(now)) {
      await _dataSource.put(preset.toRecord());
    }
  }

  @override
  Future<PaymentMethod> create(PaymentMethod method) async {
    _validate(method);
    final all = await _dataSource.getAll();
    for (final r in all) {
      if (r.name.toLowerCase() == method.name.trim().toLowerCase() && r.deletedAt == null) {
        throw AppException('A payment method named "${method.name}" already exists.');
      }
    }

    final now = DateTime.now();
    final record = method.copyWith(
      isBuiltIn: false,
      version: 1,
      createdAt: now,
      updatedAt: now,
      sortOrder: all.length,
    ).toRecord();

    final saved = await _dataSource.put(record);
    return saved.toEntity();
  }

  @override
  Future<PaymentMethod> update(PaymentMethod method) async {
    _validate(method);
    final existing = await _dataSource.getById(method.id);
    if (existing == null) throw AppException('Payment method not found.');
    if (existing.isBuiltIn && method.name != existing.name) {
      throw AppException('Cannot rename a built-in payment method.');
    }

    final now = DateTime.now();
    final record = method.copyWith(
      isBuiltIn: existing.isBuiltIn,
      updatedAt: now,
      version: existing.version + 1,
    ).toRecord();

    final saved = await _dataSource.put(record);
    return saved.toEntity();
  }

  @override
  Future<void> archive(int id) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    existing.isEnabled = false;
    existing.updatedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<void> restore(int id) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    existing.deletedAt = null;
    existing.isEnabled = true;
    existing.updatedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<void> enable(int id) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    if (existing.deletedAt != null) throw AppException('Cannot enable a deleted method.');
    existing.isEnabled = true;
    existing.updatedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<void> disable(int id) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    if (existing.isBuiltIn) throw AppException('Cannot disable a built-in payment method.');
    existing.isEnabled = false;
    existing.updatedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<void> toggleFavorite(int id) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    existing.isFavorite = !existing.isFavorite;
    existing.updatedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<void> reorder(int id, int newSortOrder) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    existing.sortOrder = newSortOrder;
    existing.updatedAt = DateTime.now();
    await _dataSource.put(existing);
  }

  @override
  Future<void> delete(int id) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) throw AppException('Payment method not found.');
    if (existing.isBuiltIn) throw AppException('Cannot delete a built-in payment method. Archive instead.');
    existing.deletedAt = DateTime.now();
    existing.isEnabled = false;
    await _dataSource.put(existing);
  }

  @override
  Future<PaymentMethod?> getById(int id) async {
    final record = await _dataSource.getById(id);
    return record?.toEntity();
  }

  @override
  Future<List<PaymentMethod>> getAll({String? searchQuery, bool? enabledOnly, bool? favoritesOnly}) async {
    final all = await _dataSource.getAll();
    var filtered = all.where((r) => r.deletedAt == null).toList();

    if (enabledOnly == true) {
      filtered = filtered.where((r) => r.isEnabled).toList();
    }
    if (favoritesOnly == true) {
      filtered = filtered.where((r) => r.isFavorite).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((r) => r.name.toLowerCase().contains(q)).toList();
    }

    filtered.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return filtered.map((r) => r.toEntity()).toList();
  }

  @override
  Future<List<PaymentMethod>> getEnabled() async => getAll(enabledOnly: true);

  @override
  Future<List<PaymentMethod>> getFavorites() async => getAll(favoritesOnly: true);

  @override
  Stream<List<PaymentMethod>> watchAll() {
    return _dataSource.watchAll().map((records) {
      return records
          .where((r) => r.deletedAt == null)
          .map((r) => r.toEntity())
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }

  void _validate(PaymentMethod m) {
    final err = m.validate();
    if (err != null) throw AppException(err);
  }
}
