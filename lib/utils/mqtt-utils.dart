import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:math';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  MqttServerClient? _client;

  MqttServerClient? get client => _client;

  Future<void> connect() async {
    if (_client != null && _client!.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }
    final randomId = 'flutter_client_${Random().nextInt(100000)}';
    _client = MqttServerClient('broker.hivemq.com', randomId);
    _client!.port = 1883;
    _client!.logging(on: true);
    _client!.keepAlivePeriod = 20;
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(randomId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;
    try {
      await _client!.connect();
    } catch (e) {
      _client!.disconnect();
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _client?.disconnect();
    _client = null;
  }
}