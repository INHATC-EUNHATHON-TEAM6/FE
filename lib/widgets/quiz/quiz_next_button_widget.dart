import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/main_screen.dart';
import 'package:words_hanjoom/widgets/button_widget.dart';

class QuizNextButtonWidget extends StatelessWidget {
  final int? wordsQuizStatus;
  final int? summaryQuizStatus;
  final bool? isFinalProblem;
  final VoidCallback? handleWordsQuizStatus;
  final VoidCallback? handleSummaryQuizStatus;
  final VoidCallback? handleWordsQuizProblemNo;
  const QuizNextButtonWidget({
    super.key,
    this.wordsQuizStatus,
    this.summaryQuizStatus,
    this.isFinalProblem,
    this.handleWordsQuizStatus,
    this.handleSummaryQuizStatus,
    this.handleWordsQuizProblemNo,
  });

  @override
  Widget build(BuildContext context) {
    final String buttonText;
    final VoidCallback handler;
    void backToHome() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    }

    if (wordsQuizStatus == 0 && handleWordsQuizStatus != null) {
      buttonText = "퀴즈 시작!";
      handler = handleWordsQuizStatus!;
    } else if (handleWordsQuizProblemNo != null && isFinalProblem != null) {
      buttonText = (isFinalProblem!) ? "결과 확인" : "다음 문제";
      handler = handleWordsQuizProblemNo!;
    } else if (wordsQuizStatus == 2 &&
        summaryQuizStatus == 0 &&
        handleSummaryQuizStatus != null) {
      buttonText = "요약 퀴즈 이동";
      handler = handleSummaryQuizStatus!;
    } else if (summaryQuizStatus == 1) {
      buttonText = "결과 확인";
      handler = handleSummaryQuizStatus!;
    } else {
      buttonText = "학습페이지로 이동";
      handler = backToHome;
    }

    return ButtonWidget(text: buttonText, hexColor: 0xfffff2c9, onTap: handler);
  }
}
