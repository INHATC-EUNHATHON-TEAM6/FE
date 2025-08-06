import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_text_widget.dart';

class WordsQuizResultWidget extends StatelessWidget {
  const WordsQuizResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 19.5),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 31),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuizTextWidget(text: "총 문제 수", weight: FontWeight.w700),
                    QuizTextWidget(text: "3문제", weight: FontWeight.w700),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuizTextWidget(text: "맞은 문제 수", weight: FontWeight.w700),
                    QuizTextWidget(text: "2문제", weight: FontWeight.w700),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    QuizTextWidget(text: "틀린 문제 수", weight: FontWeight.w700),
                    QuizTextWidget(text: "1문제", weight: FontWeight.w700),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            child: Divider(color: Color(0xff707070), thickness: 2),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 23),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    QuizTextWidget(
                      text: "어휘 추론 능력\n(1문제)",
                      size: 10,
                      weight: FontWeight.w700,
                    ),
                    SizedBox(height: 6),
                    QuizTextWidget(text: "0/1", weight: FontWeight.w700),
                  ],
                ),
                Column(
                  children: [
                    QuizTextWidget(
                      text: "어휘 설명 능력\n(1문제)",
                      size: 10,
                      weight: FontWeight.w700,
                    ),
                    SizedBox(height: 6),
                    QuizTextWidget(text: "1/1", weight: FontWeight.w700),
                  ],
                ),
                Column(
                  children: [
                    QuizTextWidget(
                      text: "어휘 식별 능력\n(1문제)",
                      size: 10,
                      weight: FontWeight.w700,
                    ),
                    SizedBox(height: 6),
                    QuizTextWidget(text: "1/1", weight: FontWeight.w700),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
