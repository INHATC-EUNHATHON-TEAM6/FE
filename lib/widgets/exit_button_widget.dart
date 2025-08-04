import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/main_screen.dart';

class ExitButtonWidget extends StatelessWidget {
  const ExitButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xfffff3eb),
          border: Border.all(color: Color(0xff3a0b0b)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icons/exit.png", width: 18),
            SizedBox(width: 4),
            Text(
              "나가기",
              style: TextStyle(
                color: Color(0xff3a0b0b),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
