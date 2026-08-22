import 'package:isar_community/isar.dart';

extension StableIsarCollection<T> on IsarCollection<T> {
  Future<List<T>> findAllRecords() {
    return buildQuery<T>().findAll();
  }

  Future<T?> findFirstByProperty(String property, Object? value) {
    return buildQuery<T>(
      filter: FilterCondition.equalTo(property: property, value: value),
    ).findFirst();
  }

  Future<Id> upsertByProperty({
    required String property,
    required Object? value,
    required T object,
    required Id Function(T object) readId,
    required void Function(T object, Id id) writeId,
  }) async {
    final existing = await findFirstByProperty(property, value);
    if (existing != null) {
      writeId(object, readId(existing));
    }
    return isar.writeTxn(() => put(object));
  }

  Future<bool> deleteFirstByProperty(
    String property,
    Object? value, {
    required Id Function(T object) readId,
  }) async {
    final existing = await findFirstByProperty(property, value);
    if (existing == null) return false;
    return isar.writeTxn(() => delete(readId(existing)));
  }
}
