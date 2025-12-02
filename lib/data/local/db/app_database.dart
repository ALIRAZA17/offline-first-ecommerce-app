import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get remoteId => integer().named('remote_id').nullable()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().named('image_url').nullable()();
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  TextColumn get tablename => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
}

@DriftDatabase(tables: [Products, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },

    onUpgrade: (m, from, to) async {
      if (from < 2 && to >= 2) {
        await m.createTable(syncQueue);
      }

      if (from < 3 && to >= 3) {
        await m.addColumn(products, products.remoteId);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
