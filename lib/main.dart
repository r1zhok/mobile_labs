import 'package:flutter/material.dart';
import 'package:test/pages/home_page.dart';
import 'package:test/pages/no_internet_page.dart';
import 'package:test/pages/welcome_page.dart';
import 'package:test/utils/network-util.dart';
import 'core/repository/shared_prefs_user_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userRepository = SharedPrefsUserRepository();
  final user = await userRepository.getUser();

  await Future.delayed(const Duration(milliseconds: 500));
  final hasInternet = await NetworkService().hasInternet();

  Widget homePage;
  if (user != null) {
    final isAuthenticated = await userRepository.authenticate(user['email']!, user['password']!);
    homePage = isAuthenticated
        ? (hasInternet ? const VibrationPage() : const NoInternetPage())
        : const WelcomePage();
  } else {
    homePage = const WelcomePage();
  }

  runApp(MyApp(home: homePage));
}

class MyApp extends StatelessWidget {
  final Widget home;
  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: home,
    );
  }
}