import 'package:flutter/material.dart';

class ActivityContentWeight extends StatelessWidget {
  final int color;
  final String text;
  const ActivityContentWeight({
    super.key,
    required this.text,
    this.color = 0xffFFF2C9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(color),
        border: Border.all(color: Color(0xff733E17)),
        borderRadius: BorderRadius.circular(6),
      ),
      width: 315,
      height: 108,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(text)],
      ),
    );
  }
}
