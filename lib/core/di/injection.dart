import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies annotated with @injectable
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
