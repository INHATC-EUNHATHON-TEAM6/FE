import 'package:flutter/material.dart';

class QuizTextWidget extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  const QuizTextWidget({
    super.key,
    required this.text,
    this.size = 14,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF3A0B0B),
        fontSize: size,
        fontWeight: weight,
      ),
    );
  }
}
