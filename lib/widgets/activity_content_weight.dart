import 'package:flutter/material.dart';

class ActivityContentWeight extends StatelessWidget {
  final int color;
  final double width, height;
  final String text;
  final Image? image;

  const ActivityContentWeight({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.image,
    this.color = 0xffFFF2C9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(color),
        border: Border.all(color: Color(0xff733E17)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4.5),
            blurRadius: 2,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ],
      ),
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) image!,
          Text(
            text,
            style: TextStyle(
              color: Color(0xff733E17),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: "NotoSansKR",
            ),
          ),
        ],
      ),
    );
  }
}
