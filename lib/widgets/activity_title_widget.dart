import 'package:flutter/material.dart';

class ActivityTitleWidget extends StatelessWidget {
  final String text;
  const ActivityTitleWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xff3a0b0b),
        fontSize: 28,
        fontFamily: "Jalnan",
        shadows: [
          Shadow(
            blurRadius: 12.0, // 그림자의 번짐 정도
            color: Colors.black.withValues(alpha: 0.3), // 그림자 색상
            offset: Offset(0.0, 4.5), // 그림자 위치 (가로, 세로)
          ),
        ],
      ),
    );
  }
}
