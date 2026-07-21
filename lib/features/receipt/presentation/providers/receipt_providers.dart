import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers/app_providers.dart';
import '../../data/datasources/isar_receipt_local_datasource.dart';
import '../../data/repositories/receipt_repository_impl.dart';

final receiptRepositoryProvider = Provider((ref) {
  final isar = ref.watch(isarProvider);
  return ReceiptRepositoryImpl(IsarReceiptLocalDataSource(isar));
});

final receiptListProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(receiptRepositoryProvider).watchAll();
});
