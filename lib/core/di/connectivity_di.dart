import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ConnectivityDI {
  final Connectivity connectivity;

  ConnectivityDI() : connectivity = Connectivity();
}
