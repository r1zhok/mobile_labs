import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/registration_page.dart';
import 'package:test/widgets/custom_button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final Duration _duration = Duration(seconds: 4);
  final List<List<Color>> _gradients = [
    [Colors.blue.shade900, Colors.blue.shade400],
    [Colors.purple.shade700, Colors.pink.shade500],
    [Colors.green.shade700, Colors.blue.shade300],
  ];

  int _currentGradientIndex = 0;

  void _changeBackground() {
    setState(() {
      _currentGradientIndex = (_currentGradientIndex + 1) % _gradients.length;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), _cycleGradients);
  }

  void _cycleGradients() {
    Future.delayed(_duration, () {
      _changeBackground();
      _cycleGradients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _gradients[_currentGradientIndex],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to MyApp',
                  style: GoogleFonts.lobster(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  text: 'Login',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                SizedBox(height: 10),
                CustomButton(
                  text: 'Register',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}