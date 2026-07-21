import 'dart:convert';
import 'dart:typed_data';
import 'package:xxh3/xxh3.dart';

void main() {
  for (final n in ['PaymentRequestRecord', 'PaymentSessionRecord']) {
    final h = xxh3(Uint8List.fromList(utf8.encode(n)));
    print('$n -> $h');
  }
}
