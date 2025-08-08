import 'package:flutter/material.dart';

class ModalWidget extends StatelessWidget {
  final VoidCallback? onYesPressed;
  final VoidCallback? onNoPressed;

  const ModalWidget({super.key, this.onYesPressed, this.onNoPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 73),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(21),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 35),
            Text(
              "독해를 종료하시겠습니까?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff3a0b0b),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 21, horizontal: 21),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onYesPressed != null) {
                          onYesPressed!();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: Color(0xff8B4513),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          "네",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onNoPressed != null) {
                          onNoPressed!();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF3EB),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: Color(0xFF733E17),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "아니요",
                          style: TextStyle(
                            color: Color(0xFF733E17),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
