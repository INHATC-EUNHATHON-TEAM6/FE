import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/exit_button_widget.dart';
import 'package:words_hanjoom/widgets/quiz/words_quiz_content_widget.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_next_button_widget.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_title_widget.dart';
import 'package:words_hanjoom/widgets/quiz/summary_quiz_content_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // 0: 시작 전, 1: 진행 중, 2: 완료
  int wordsQuizStatus = 0;
  // 0: 시작 전, 1: 진행 중, 2: 완료
  int summaryQuizStatus = 0;
  @override
  Widget build(BuildContext context) {
    void handleWordsQuizStatus() {
      setState(() {
        wordsQuizStatus += 1;
      });
    }

    void handleSummaryQuizStatus() {
      setState(() {
        summaryQuizStatus += 1;
      });
    }

    return Scaffold(
      backgroundColor: Color(0xfff3f3f3),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [ExitButtonWidget()],
            ),
            if (wordsQuizStatus == 0 ||
                (wordsQuizStatus == 2 && summaryQuizStatus == 0) ||
                summaryQuizStatus == 2)
              QuizTitleWidget(
                wordsQuizStatus: wordsQuizStatus,
                summaryQuizStatus: summaryQuizStatus,
              ),
            (summaryQuizStatus == 0)
                ? WordsQuizContentWidget(
                    wordsQuizStatus: wordsQuizStatus,
                    handleWordsQuizStatus: handleWordsQuizStatus,
                  )
                : SummaryQuizContentWidget(
                    summaryQuizStatus: summaryQuizStatus,
                    handleSummaryQuizStatus: handleSummaryQuizStatus,
                  ),
            if (wordsQuizStatus == 0 ||
                (wordsQuizStatus == 2 && summaryQuizStatus == 0) ||
                summaryQuizStatus == 2)
              QuizNextButtonWidget(
                wordsQuizStatus: wordsQuizStatus,
                summaryQuizStatus: summaryQuizStatus,
                handleWordsQuizStatus: handleWordsQuizStatus,
                handleSummaryQuizStatus: handleSummaryQuizStatus,
              ),
          ],
        ),
      ),
    );
  }
}
