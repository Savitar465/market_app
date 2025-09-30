import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class AuthCredentialsTable extends Table {
  TextColumn get userId => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get hashedPassword => text()();
  TextColumn get passwordSalt => text()();
  TextColumn get encryptedAccessToken => text()();
  TextColumn get encryptedRefreshToken => text().nullable()();
  IntColumn get expiresAt => integer().nullable()();
  TextColumn get jsonUserMetadata => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DriftDatabase(tables: [AuthCredentialsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<AuthCredentialsTableData?> fetchCachedCredentials() {
    return select(authCredentialsTable).getSingleOrNull();
  }

  Future<AuthCredentialsTableData?> fetchCredentialsByEmail(String email) {
    return (select(authCredentialsTable)..where((tbl) => tbl.email.equals(email)))
        .getSingleOrNull();
  }

  Future<void> saveCredentials(AuthCredentialsTableCompanion entry) {
    return into(authCredentialsTable).insertOnConflictUpdate(entry);
  }

  Future<void> clearCredentials() {
    return delete(authCredentialsTable).go();
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'market_app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
