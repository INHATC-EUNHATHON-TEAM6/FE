import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_next_button_widget.dart';

class SummaryQuizContentWidget extends StatelessWidget {
  final int summaryQuizStatus;
  final VoidCallback handleSummaryQuizStatus;
  const SummaryQuizContentWidget({
    super.key,
    required this.summaryQuizStatus,
    required this.handleSummaryQuizStatus,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    double marginTop;
    if (summaryQuizStatus == 1) {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 21),
        child: Column(
          children: [
            Text("읽은 지문의 핵심 내용을 요약하세요.", style: TextStyle(fontSize: 16)),
            Container(
              margin: EdgeInsets.only(top: 19, left: 9, right: 9),
              height: 318,
              decoration: BoxDecoration(
                color: Color(0xfff8f8f8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xffe0e0e0)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: TextField(
                maxLines: 17,
                minLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '요약문을 작성하세요.',
                  hintStyle: TextStyle(color: Color(0xff5D6470)),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 24),
              child: QuizNextButtonWidget(
                summaryQuizStatus: summaryQuizStatus,
                handleSummaryQuizStatus: handleSummaryQuizStatus,
              ),
            ),
          ],
        ),
      );
    } else {
      content = Column(children: [Container(width: 280, height: 339)]);
    }
    if (summaryQuizStatus == 1) {
      marginTop = 63;
    } else {
      marginTop = 21;
    }
    return Container(
      margin: EdgeInsets.only(top: marginTop, left: 32, right: 32, bottom: 17),
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
