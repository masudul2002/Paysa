import 'package:xxh3/xxh3.dart';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  const name = 'AccountRecord';

  // xxh3 64-bit hash
  final bytes = Uint8List.fromList(utf8.encode(name));
  final hash = xxh3(bytes);
  print('xxh3-64 of "$name": $hash');
  print('xxh3-64 signed: ${hash.toSigned(64)}');

  // Also compute for index name
  const indexName = 'name';
  final indexBytes = Uint8List.fromList(utf8.encode(indexName));
  final indexHash = xxh3(indexBytes);
  print('xxh3-64 of "$indexName": $indexHash');
  print('xxh3-64 signed: ${indexHash.toSigned(64)}');
}
