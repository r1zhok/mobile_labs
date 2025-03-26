import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/pages/profile_page.dart';
import 'package:vibration/vibration.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../utils/network-util.dart';

class VibrationPage extends StatefulWidget {
  const VibrationPage({super.key});

  @override
  State<VibrationPage> createState() => _VibrationPageState();
}

class _VibrationPageState extends State<VibrationPage> {
  final client = MqttServerClient('broker.hivemq.com', 'flutter_client_${Random().nextInt(10000)}');
  bool _connected = false;
  bool _isConnectedToInternet = true;
  String _mqttMessage = 'Нічого не прийшло'; // Текст по замовчуванню

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
    _subscribeToNetworkChanges();
  }

  void _subscribeToNetworkChanges() {
    final networkService = NetworkService();
    networkService.onStatusChange.listen((isConnected) {
      setState(() {
        _isConnectedToInternet = isConnected; // Оновлюємо статус
      });
    });
  }

  Future<void> _connectToMqtt() async {
    client.port = 1883;
    client.logging(on: true);  // Увімкніть логи для більш детальної інформації
    client.keepAlivePeriod = 20;

    client.onDisconnected = () => debugPrint('MQTT disconnected');
    client.onConnected = () => debugPrint('MQTT connected');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier!)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      debugPrint('Attempting to connect to MQTT...');
      await client.connect();
      // Перевірка на підключення
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        setState(() => _connected = true);
        debugPrint('MQTT connected successfully!');
        client.subscribe('flutter/vibration', MqttQos.atMostOnce);
        client.updates?.listen(_onMessage);
      } else {
        debugPrint('MQTT connection failed: ${client.connectionStatus}');
        setState(() => _connected = false);
      }
    } catch (e) {
      debugPrint('MQTT connection error: $e');
      setState(() => _connected = false); // Встановіть статус помилки
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) async {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    debugPrint('Received MQTT message: $payload');

    if (payload == 'vibrate') {
      await _vibrateRandom();
      setState(() {
        _mqttMessage = 'Повідомлення отримано: Вібрація';
      });
    } else {
      setState(() {
        _mqttMessage = 'Нічого не прийшло';
      });
    }
  }

  Future<void> _vibrateRandom() async {
    final hasVibrator = await Vibration.hasVibrator();
    final random = Random();
    final duration = random.nextInt(1500) + 100;

    if (hasVibrator) {
      Vibration.vibrate(duration: duration);
      debugPrint('Вібрація: $duration мс');
    } else {
      HapticFeedback.mediumImpact();
      debugPrint('Тактильний відгук (fallback)');
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Вийти з додатку?'),
        content: const Text('Ви впевнені, що хочете вийти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ні'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Так'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vibration Page'),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Текст повідомлення про стан MQTT
                Text(
                  _mqttMessage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Перехід до профілю
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Перейти до профілю',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (!_connected)
                  const Text(
                    'З’єднання з брокером...',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  const Text(
                    'MQTT підключено!',
                    style: TextStyle(color: Colors.green),
                  ),
                const SizedBox(height: 24),
                // Виведемо статус підключення до Інтернету
                if (!_isConnectedToInternet)
                  const Text(
                    'Немає підключення до Інтернету!',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  const Text(
                    'Інтернет підключено!',
                    style: TextStyle(color: Colors.green),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}