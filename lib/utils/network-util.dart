import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatusChange => _controller.stream;

  static final NetworkService _instance = NetworkService._privateConstructor();
  factory NetworkService() => _instance;

  NetworkService._privateConstructor() {
    Connectivity().onConnectivityChanged.listen((_) async {
      final hasConnection = await hasInternet();
      _controller.sink.add(hasConnection);
    });
  }

  Future<bool> hasInternet() async {
    return await InternetConnectionChecker().hasConnection;
  }

  void dispose() => _controller.close();
}