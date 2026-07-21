import '../entities/payment_method.dart';

abstract interface class PaymentMethodRepository {
  Future<void> initializeDefaults();
  Future<PaymentMethod> create(PaymentMethod method);
  Future<PaymentMethod> update(PaymentMethod method);
  Future<void> archive(int id);
  Future<void> restore(int id);
  Future<void> enable(int id);
  Future<void> disable(int id);
  Future<void> toggleFavorite(int id);
  Future<void> reorder(int id, int newSortOrder);
  Future<void> delete(int id);
  Future<PaymentMethod?> getById(int id);
  Future<List<PaymentMethod>> getAll({String? searchQuery, bool? enabledOnly, bool? favoritesOnly});
  Future<List<PaymentMethod>> getEnabled();
  Future<List<PaymentMethod>> getFavorites();
  Stream<List<PaymentMethod>> watchAll();
}
