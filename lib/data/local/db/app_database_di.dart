import 'package:injectable/injectable.dart';
import 'package:offline_ecommerce/data/local/db/app_database.dart';

@LazySingleton()
class AppDatabaseProvider {
  final AppDatabase db = AppDatabase();
}