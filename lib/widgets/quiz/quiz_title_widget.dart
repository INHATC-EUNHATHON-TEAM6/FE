import 'package:flutter/material.dart';

class QuizTitleWidget extends StatelessWidget {
  final int wordsQuizStatus, summaryQuizStatus;
  const QuizTitleWidget({
    super.key,
    required this.wordsQuizStatus,
    required this.summaryQuizStatus,
  });

  @override
  Widget build(BuildContext context) {
    final String title;
    final double fontSize;
    final double marginTop;
    if (wordsQuizStatus == 0) {
      title = "퀴즈 순서는\n'어휘 퀴즈 → 요약 퀴즈' 입니다.";
      fontSize = 20;
      marginTop = 87;
    } else if (wordsQuizStatus == 2 && summaryQuizStatus == 0) {
      title = "어휘 퀴즈 최종 결과";
      fontSize = 24;
      marginTop = 97;
    } else {
      title = "요약 퀴즈 최종 결과";
      fontSize = 24;
      marginTop = 52;
    }
    return Container(
      margin: EdgeInsets.only(top: marginTop),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xff733E17),
          fontSize: fontSize,
          fontFamily: "Jalnan",
        ),
      ),
    );
  }
}
