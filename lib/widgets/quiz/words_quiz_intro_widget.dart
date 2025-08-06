import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_text_widget.dart';

class WordsQuizIntroWidget extends StatelessWidget {
  final List<Map<String, dynamic>> problems;
  const WordsQuizIntroWidget({super.key, required this.problems});

  @override
  Widget build(BuildContext context) {
    List<int> types = [0, 0, 0];
    for (var problem in problems) {
      types[problem['type'] - 1] += 1;
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 45),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "어휘퀴즈",
            style: TextStyle(
              color: Color(0xff733E17),
              fontSize: 18,
              fontFamily: "Jalnan",
            ),
          ),
          SizedBox(height: 7),
          QuizTextWidget(
            text: "총 ${problems.length}문제",
            size: 14,
            weight: FontWeight.w500,
          ),
          SizedBox(height: 21),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuizTextWidget(text: "어휘 추론 문제", weight: FontWeight.w500),
              QuizTextWidget(text: "${types[0]}문제", weight: FontWeight.w500),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuizTextWidget(text: "어휘 의미 문제", weight: FontWeight.w500),
              QuizTextWidget(text: "${types[1]}문제", weight: FontWeight.w500),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuizTextWidget(text: "어휘 맞추기 문제", weight: FontWeight.w500),
              QuizTextWidget(text: "${types[2]}문제", weight: FontWeight.w500),
            ],
          ),
        ],
      ),
    );
  }
}
