/// Mappers between domain entities and Firestore documents.
///
/// Each mapper handles serialization and deserialization.
/// Firestore stores maps with string keys and supports
/// nested data, timestamps, and GeoPoints.
abstract class FirestoreMapper<T> {
  /// Convert a domain entity to a Firestore document map.
  Map<String, dynamic> toFirestore(T entity);

  /// Convert a Firestore document map to a domain entity.
  T fromFirestore(Map<String, dynamic> data, String id);

  /// Convert a list of Firestore documents to domain entities.
  List<T> listFromFirestore(List<Map<String, dynamic>> docs) {
    return docs.map((d) => fromFirestore(Map.from(d), d['id'] as String? ?? '')).toList();
  }
}

/// Generic mapper for entities with id, version, createdAt, updatedAt.
mixin TimestampMixin {
  Map<String, dynamic> addTimestamps(Map<String, dynamic> data, {int? version}) {
    return {
      ...data,
      'version': (version ?? 1),
      'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
