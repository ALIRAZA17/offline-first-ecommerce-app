import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Table: Products (existing)
class Products extends Table {
  // local primary key (auto incremented by Drift/SQLite)
  IntColumn get id => integer().autoIncrement()();

  // remote/supabase id (nullable) — stored in DB column 'remote_id'
  IntColumn get remoteId => integer().named('remote_id').nullable()();

  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock => integer()();
  TextColumn get description => text().nullable()();
  // keep consistent name with Supabase column 'image_url' if you use that there
  TextColumn get imageUrl => text().named('image_url').nullable()();
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

  // Bump schema version because we added a column/changed schema
  @override
  int get schemaVersion => 3;

  // Migration strategy: create missing table(s) on upgrade
  @override
  MigrationStrategy get migration => MigrationStrategy(
        // onCreate is called when DB is first created
        onCreate: (m) async {
          await m.createAll();
        },

        // onUpgrade runs when schemaVersion increases
        onUpgrade: (m, from, to) async {
          // if previous schema didn't have sync queue, create it
          if (from < 2 && to >= 2) {
            await m.createTable(syncQueue);
          }

          // add remote_id column added in version 3
          if (from < 3 && to >= 3) {
            // add the new column to products
            await m.addColumn(products, products.remoteId);
          }
        },

        // onDowngrade can be added if needed.
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
