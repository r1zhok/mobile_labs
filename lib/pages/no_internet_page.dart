import 'package:flutter/material.dart';

import '../utils/network-util.dart';
import 'home_page.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  bool _isConnectedToInternet = false;

  @override
  void initState() {
    super.initState();
    _subscribeToNetworkChanges();
  }

  void _subscribeToNetworkChanges() {
    final networkService = NetworkService();
    networkService.onStatusChange.listen((isConnected) {
      setState(() {
        _isConnectedToInternet = isConnected;
      });

      if (_isConnectedToInternet) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VibrationPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Немає Інтернету'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: _isConnectedToInternet
            ? const CircularProgressIndicator()
            : const Text(
          'Будь ласка, підключіться до Інтернету, щоб продовжити.',
          style: TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}