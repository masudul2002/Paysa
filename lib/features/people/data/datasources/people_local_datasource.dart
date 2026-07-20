import '../models/person_record.dart';

/// Abstract local data source for people persistence.
///
/// Implementations provide the actual storage (Isar, in-memory for tests).
abstract interface class PeopleLocalDataSource {
  /// Insert or update a person record. Returns the saved record.
  Future<PersonRecord> put(PersonRecord record);

  /// Get a person by local ID. Returns null if not found.
  Future<PersonRecord?> getById(int id);

  /// Get a person by phone number. Returns null if not found.
  Future<PersonRecord?> getByPhone(String phone);

  /// Get all non-deleted person records.
  Future<List<PersonRecord>> getAll();

  /// Stream all person records reactively.
  Stream<List<PersonRecord>> watchAll();

  /// Permanently delete a person record by ID.
  Future<void> delete(int id);
}
