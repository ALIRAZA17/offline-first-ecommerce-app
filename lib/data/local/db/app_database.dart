import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Table: Products
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get price => real()();
  IntColumn get stock => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
}

/// Drift database
@DriftDatabase(tables: [Products])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
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
