import 'package:flutter/material.dart';

class ReadingTextWidget extends StatelessWidget {
  const ReadingTextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            // withValues는 비표준 메서드일 수 있습니다. withOpacity()를 사용하세요.
            color: Colors.black.withValues(alpha: 0.25),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Scrollbar(
        controller: controller,
        thickness: 8,
        radius: Radius.circular(4),
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 9.5),
          child: Text(
            "hihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiiihihihihihiii",
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
