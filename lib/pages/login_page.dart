import 'package:flutter/material.dart';
import 'package:test/widgets/custom_button.dart';
import 'package:test/pages/home_page.dart';
import 'package:test/pages/registration_page.dart';

import '../core/repository/shared_prefs_user_repository.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Duration duration;
  final List<List<Color>> gradients;
  final int currentGradientIndex;
  final Function() onBackPressed;

  const CustomAppBar({
    super.key,
    required this.duration,
    required this.gradients,
    required this.currentGradientIndex,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradients[currentGradientIndex],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBackPressed,
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _repo = SharedPrefsUserRepository();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final isValid = await _repo.authenticate(
        _emailController.text,
        _passwordController.text,
      );
      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VibrationPage()),
        );
      } else {
        print('not valid');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    }
  }

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
      appBar: CustomAppBar(
        duration: _duration,
        gradients: _gradients,
        currentGradientIndex: _currentGradientIndex,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Login to your account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(Icons.email, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withAlpha(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(Icons.lock, color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withAlpha(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            obscureText: true,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: 'Login',
                            onPressed: _login,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegistrationPage()),
                              );
                            },
                            child: Text(
                              'Don\'t have an account? Register',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}