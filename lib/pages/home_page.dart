import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/pages/profile_page.dart';
import 'package:vibration/vibration.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../utils/mqtt-utils.dart';
import '../utils/network-util.dart';

class VibrationPage extends StatefulWidget {
  const VibrationPage({super.key});

  @override
  State<VibrationPage> createState() => _VibrationPageState();
}

class _VibrationPageState extends State<VibrationPage> {
  bool _connected = false;
  bool _isConnectedToInternet = true;
  String _mqttMessage = 'Нічого не прийшло';
  StreamSubscription? _mqttSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToNetworkChanges();
    _setupMqtt();
  }

  void _subscribeToNetworkChanges() {
    final networkService = NetworkService();
    networkService.onStatusChange.listen((isConnected) {
      setState(() {
        _isConnectedToInternet = isConnected;
      });
      if (isConnected && !_connected) {
        _setupMqtt();
      }
    });
  }

  void _setupMqtt() async {
    await MQTTService().connect();
    final client = MQTTService().client;
    if (client != null && client.connectionStatus?.state == MqttConnectionState.connected) {
      setState(() => _connected = true);
      client.subscribe('flutter/vibration', MqttQos.atMostOnce);
      _mqttSubscription?.cancel();
      _mqttSubscription = client.updates?.listen((messages) {
        print('MQTT message received: $messages');
        _onMessage(messages);
      });
    } else {
      setState(() => _connected = false);
      print('Failed to connect: ${client?.connectionStatus}');
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) async {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print('Received payload: "$payload"');
    if (payload.trim() == 'vibrate') {
      await _vibrateRandom();
      setState(() {
        _mqttMessage = 'Повідомлення отримано: Вібрація';
      });
    } else {
      setState(() {
        _mqttMessage = 'Отримано: "$payload"';
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
    _mqttSubscription?.cancel();
    MQTTService().disconnect();
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
                Text(
                  _mqttMessage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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