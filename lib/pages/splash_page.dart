import 'package:flutter/material.dart';
import 'package:test/pages/home_page.dart';

import '../utils/mqtt-utils.dart';
import '../utils/network-util.dart';
import 'no_internet_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _mqttConnected = false;

  @override
  void initState() {
    super.initState();
    _handleStartupLogic();
    _listenToNetworkChanges();
  }

  Future<void> _handleStartupLogic() async {
    final hasInternet = await NetworkService().hasInternet();
    print(hasInternet);
    final user = await _autoLogin();

    if (user != null) {
      if (!hasInternet) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NoInternetPage()),
        );
      } else {
        await MQTTService().connect();
        _mqttConnected = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VibrationPage()),
        );
      }
    }
  }

  void _listenToNetworkChanges() {
    NetworkService().onStatusChange.listen((connected) async {
      if (connected && !_mqttConnected) {
        await MQTTService().connect();
        _mqttConnected = true;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Інтернет відновлено, MQTT підключено')),
          );
        }
      }

      if (!connected && _mqttConnected) {
        await MQTTService().disconnect();
        _mqttConnected = false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Інтернет втрачено, MQTT вимкнено')),
          );
        }
      }
    });
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Немає Інтернету'),
        content: const Text('Доступ до MQTT буде обмежено. Деякі функції не працюватимуть.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<String?> _autoLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'mock_user';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Перевірка з\'єднання'),
      ),
      body: Center(
        child: FutureBuilder<bool>(
          future: NetworkService().hasInternet(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Помилка перевірки з\'єднання');
            } else if (snapshot.data == false) {
              return const Text('Немає Інтернету');
            } else {
              return const Text('Інтернет підключений');
            }
          },
        ),
      ),
    );
  }
}