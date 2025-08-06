import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/quiz/words_quiz_intro_widget.dart';
import 'package:words_hanjoom/widgets/quiz/words_quiz_problem_widget.dart';
import 'package:words_hanjoom/widgets/quiz/words_quiz_result_widget.dart';

class WordsQuizContentWidget extends StatelessWidget {
  final int wordsQuizStatus;
  final VoidCallback handleWordsQuizStatus;

  const WordsQuizContentWidget({
    super.key,
    required this.wordsQuizStatus,
    required this.handleWordsQuizStatus,
  });

  @override
  Widget build(BuildContext context) {
    final double marginTop, marginBottom;
    final Widget content;
    List<Map<String, dynamic>> problems = [
      {
        "type": 1,
        "description":
            "정의;현대 사회에서 정의는 크게 세 가지 측면에서 이해될 수 있습니다. 첫째, 법적 정의 입니다. 이는 법률에 따라 공정하게 판단하고 처벌하는 것을 의미합니다. 예를 들어, 같은 범죄를 저지른 사람들에게 동일한 처벌을 내리는 것이 법적 정의에 부합합니다.",
      },
      {"type": 2, "description": "어떤 말이나 사물의 뜻을 명백히 밝혀 규정한다."},
      {"type": 3, "description": "강의"},
    ];
    if (wordsQuizStatus == 0) {
      marginTop = marginBottom = 62;
      content = WordsQuizIntroWidget(problems: problems);
    } else if (wordsQuizStatus == 1) {
      marginTop = 63;
      marginBottom = 0;
      content = WordsQuizProblemWidget(
        problems: problems,
        handleWordsQuizStatus: handleWordsQuizStatus,
      );
    } else {
      marginTop = 67;
      marginBottom = 67;
      content = WordsQuizResultWidget();
    }

    return Container(
      margin: EdgeInsets.only(
        top: marginTop,
        bottom: marginBottom,
        left: 40,
        right: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: content,
    );
  }
}
