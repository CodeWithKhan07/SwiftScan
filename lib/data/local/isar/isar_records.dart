import 'package:isar_community/isar.dart';

part 'isar_records.g.dart';

@collection
class DocumentRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String documentId;

  @Index()
  late DateTime updatedAt;

  late String payload;
}

@collection
class KeyValueRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String value;
}
