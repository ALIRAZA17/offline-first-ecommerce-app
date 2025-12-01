import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Table: Products (existing)
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
}

/// NEW: Sync queue table for offline-first queued operations
/// We store the operation type, the target table (e.g. "products"),
/// a JSON payload (string) and a createdAt timestamp.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()(); // "add" | "update" | "delete"
  TextColumn get tablename => text()(); // "products", etc.
  TextColumn get payload => text()(); // JSON encoded payload
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}

@DriftDatabase(tables: [Products, SyncQueue])
class AppDatabase extends _$AppDatabase {
  // If the DB file already exists on devices, we'll migrate to the new schema.
  AppDatabase() : super(_openConnection());

  // Bump schema version because we added a table
  @override
  int get schemaVersion => 2;

  // Migration strategy: create missing table(s) on upgrade
  @override
  MigrationStrategy get migration => MigrationStrategy(
        // onCreate is called when DB is first created
        onCreate: (m) async {
          await m.createAll();
        },

        // onUpgrade runs when schemaVersion increases
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Create the new table(s) added in schema version 2.
            // This will create the SyncQueue table without touching existing data.
            await m.createTable(syncQueue);
          }
        },

        // You can also provide onDowngrade if needed in the future.
      );
}

/// LazyDatabase ensures DB is opened only when needed
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Get platform-specific documents folder
    final dbFolder = await getApplicationDocumentsDirectory();

    // Join folder with filename in a cross-platform safe way
    final file = File(p.join(dbFolder.path, 'app.db'));

    return NativeDatabase(file);
  });
}
