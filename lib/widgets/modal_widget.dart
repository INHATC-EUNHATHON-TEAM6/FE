import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String message;
  final VoidCallback onYes;
  final VoidCallback? onNo;

  const ConfirmDialog({
    Key? key,
    required this.message,
    required this.onYes,
    this.onNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 47),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 200, // 고정 세로
        child: Padding(
          padding: const EdgeInsets.fromLTRB(43, 72, 43, 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 메시지
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF733E17),
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "네" 버튼
                  SizedBox(
                    width: 78,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onYes,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF733E17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        '네',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Noto Sans KR',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // "아니요" 버튼
                  SizedBox(
                    width: 78,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onNo ?? () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF7ECD2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        '아니요',
                        style: TextStyle(
                          color: Color(0xFF733E17),
                          fontFamily: 'Noto Sans KR',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
