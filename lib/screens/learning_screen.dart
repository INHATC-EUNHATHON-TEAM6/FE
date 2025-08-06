import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/main_screen.dart';
import 'package:words_hanjoom/widgets/button_widget.dart';
import 'package:words_hanjoom/widgets/exit_button_widget.dart';
import 'package:words_hanjoom/widgets/reading_guide_widget.dart';
import 'package:words_hanjoom/widgets/reading_text_widget.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool isTranslating = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f3f3),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            ExitButtonWidget(text: "나가기", destination: MainScreen()),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ReadingGuideWidget(isTranslating: isTranslating),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(children: [Expanded(child: ReadingTextWidget())]),
            SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: "쉬운 내용으로 번역",
                    hexColor: 0xfffff2c9,
                    onTap: () {
                      setState(() {
                        isTranslating = true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ButtonWidget(text: "선택 취소", hexColor: 0xffffc9ce),
                ),
              ],
            ),
            SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(text: "퀴즈 시작", hexColor: 0xffc9ffcf),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
