import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_next_button_widget.dart';
import 'package:words_hanjoom/widgets/quiz/quiz_text_widget.dart';

class WordsQuizProblemWidget extends StatefulWidget {
  final List<Map<String, dynamic>> problems;
  final VoidCallback handleWordsQuizStatus;
  const WordsQuizProblemWidget({
    super.key,
    required this.problems,
    required this.handleWordsQuizStatus,
  });

  @override
  State<StatefulWidget> createState() => _WordsQuizProblemWidgetState();
}

class _WordsQuizProblemWidgetState extends State<WordsQuizProblemWidget> {
  int curProblemNo = 1;
  void handleWordsQuizProblemNo() {
    setState(() {
      if (curProblemNo == widget.problems.length) {
        widget.handleWordsQuizStatus();
        return;
      }
      curProblemNo += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String problemDesc;
    final Widget problemType;
    Map<String, dynamic> curProblem = widget.problems[curProblemNo - 1];
    if (curProblem['type'] == 1) {
      problemDesc = "빈칸에 알맞은 어휘를 입력하세요.";
      problemType = Column(
        children: [
          Container(
            width: 231,
            height: 196,
            margin: EdgeInsets.only(bottom: 12),
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
          ),
          Container(
            margin: EdgeInsets.only(top: 0, bottom: 27, left: 4, right: 4),
            height: 38,
            decoration: BoxDecoration(
              color: Color(0xfff8f8f8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xffe0e0e0)),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '어휘를 입력하세요.',
                hintStyle: TextStyle(color: Color(0xff5D6470), fontSize: 11),
                contentPadding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 0, // 위쪽 패딩
                  bottom: 14, // 아래쪽 패딩 (위쪽과 동일하게)
                ),
              ),
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      );
    } else if (curProblem['type'] == 2) {
      problemDesc = "어휘의 의미에 맞는\n적절한 어휘를 입력하세요.";
      problemType = Column(
        children: [
          Container(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${curProblem['description']}",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 0, bottom: 108),
            height: 38,
            decoration: BoxDecoration(
              color: Color(0xfff8f8f8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xffe0e0e0)),
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '어휘를 입력하세요.',
                hintStyle: TextStyle(color: Color(0xff5D6470), fontSize: 11),
                contentPadding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 0, // 위쪽 패딩
                  bottom: 14, // 아래쪽 패딩 (위쪽과 동일하게)
                ),
              ),
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      );
    } else {
      problemDesc = "${curProblem['description']}의 의미를 설명하세요.";
      problemType = Container(
        margin: EdgeInsets.only(top: 45, bottom: 84),
        height: 146,
        decoration: BoxDecoration(
          color: Color(0xfff8f8f8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xffe0e0e0)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: TextField(
          maxLines: 6,
          minLines: 4,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '의미를 입력하세요.',
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          style: TextStyle(fontSize: 12),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              QuizTextWidget(
                text: "총 ${widget.problems.length}문제",
                weight: FontWeight.w500,
              ),
            ],
          ),
          SizedBox(height: 27),
          Text(
            "문제 $curProblemNo",
            style: TextStyle(
              color: Color(0xff733E17),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: "Jalnan",
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 9, horizontal: 0),
                child: Text(
                  problemDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          problemType,
          QuizNextButtonWidget(
            handleWordsQuizProblemNo: handleWordsQuizProblemNo,
            isFinalProblem: (curProblemNo == widget.problems.length),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
