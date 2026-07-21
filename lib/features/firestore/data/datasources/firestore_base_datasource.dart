import 'dart:convert';

/// Base class for Firestore datasources.
///
/// Provides serialization helpers and document mapping.
/// In production, this wraps `FirebaseFirestore.instance.collection(name)`.
class FirestoreBaseDataSource {
  /// Simulated document storage for MVP.
  /// In production, this reads/writes to Firestore.
  final _store = <String, List<Map<String, dynamic>>>{};

  /// Get all documents from a collection.
  Future<List<Map<String, dynamic>>> getAll(String collection) async {
    return List.from(_store[collection] ?? []);
  }

  /// Get a document by ID.
  Future<Map<String, dynamic>?> getById(String collection, String id) async {
    final docs = _store[collection] ?? [];
    for (final doc in docs) {
      if (doc['id'] == id) return Map.from(doc);
    }
    return null;
  }

  /// Upsert a document.
  Future<void> upsert(String collection, String id, Map<String, dynamic> data) async {
    _store.putIfAbsent(collection, () => []);
    _store[collection]!.removeWhere((d) => d['id'] == id);
    _store[collection]!.add({'id': id, ...data, 'updatedAt': DateTime.now().toIso8601String()});
  }

  /// Delete a document.
  Future<void> delete(String collection, String id) async {
    _store[collection]?.removeWhere((d) => d['id'] == id);
  }

  /// Add a server timestamp field (placeholder for Firestore's FieldValue.serverTimestamp()).
  static String serverTimestamp() => DateTime.now().toIso8601String();
}
