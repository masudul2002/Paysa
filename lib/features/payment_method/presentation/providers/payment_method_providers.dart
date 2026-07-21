import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_payment_method_local_datasource.dart';
import '../../data/repositories/payment_method_repository_impl.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/repositories/payment_method_repository.dart';

final paymentMethodRepositoryProvider = Provider<PaymentMethodRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return PaymentMethodRepositoryImpl(IsarPaymentMethodLocalDataSource(isar));
});

// Filters / sort
final paymentMethodSearchProvider = StateProvider<String>((ref) => '');
final paymentMethodEnabledOnlyProvider = StateProvider<bool>((ref) => false);
final paymentMethodFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

final paymentMethodListProvider = StreamProvider.autoDispose<List<PaymentMethod>>((ref) {
  final repo = ref.watch(paymentMethodRepositoryProvider);
  final search = ref.watch(paymentMethodSearchProvider);
  final enabledOnly = ref.watch(paymentMethodEnabledOnlyProvider);
  final favoritesOnly = ref.watch(paymentMethodFavoritesOnlyProvider);

  return repo.watchAll().map((methods) {
    var filtered = methods.toList();
    if (enabledOnly) filtered = filtered.where((m) => m.isEnabled).toList();
    if (favoritesOnly) filtered = filtered.where((m) => m.isFavorite).toList();
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) filtered = filtered.where((m) => m.name.toLowerCase().contains(q)).toList();
    return filtered;
  });
});

final paymentMethodEnabledListProvider = Provider.autoDispose<Future<List<PaymentMethod>>>((ref) {
  final repo = ref.watch(paymentMethodRepositoryProvider);
  return repo.getEnabled();
});

final selectedPaymentMethodProvider = StateProvider<PaymentMethod?>((ref) => null);
