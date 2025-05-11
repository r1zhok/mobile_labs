import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  final List<List<Color>> _gradients = [
    [Colors.blue.shade900, Colors.blue.shade400],
    [Colors.purple.shade700, Colors.pink.shade500],
    [Colors.green.shade700, Colors.blue.shade300],
  ];

  int _currentGradientIndex = 0;

  void _changeGradient() {
    setState(() {
      _currentGradientIndex = (_currentGradientIndex + 1) % _gradients.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _cycleGradients();
  }

  void _cycleGradients() {
    Future.delayed(Duration(seconds: 4), () {
      _changeGradient();
      _cycleGradients(); // Keep cycling the gradients
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 4),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradients[_currentGradientIndex],
        ),
      ),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}