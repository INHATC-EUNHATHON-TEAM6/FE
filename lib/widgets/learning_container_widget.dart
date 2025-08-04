import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/activity_content_widget.dart';
import 'package:words_hanjoom/widgets/activity_title_widget.dart';

class LearningContainerWidget extends StatelessWidget {
  final void Function(String) handleMainScreenWidget;
  const LearningContainerWidget({
    super.key,
    required this.handleMainScreenWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActivityTitleWidget(text: "독해활동"),
          SizedBox(height: 9),
          Row(
            children: [
              Column(
                children: [
                  ActivityContentWidget(
                    text: "분야선택",
                    width: 153,
                    height: 188,
                    image: Image.asset(
                      "assets/icons/fields_select.png",
                      width: 48,
                    ),
                    onTap: () => handleMainScreenWidget("fields_select"),
                  ),
                ],
              ),
              SizedBox(width: 9),
              Column(
                children: [
                  ActivityContentWidget(
                    text: "랜덤지문",
                    width: 153,
                    height: 107,
                    image: Image.asset("assets/icons/random.png", width: 44),
                    color: 0xfffde186,
                  ),
                  SizedBox(height: 10),
                  ActivityContentWidget(
                    text: "OCR",
                    width: 153,
                    height: 71,
                    image: Image.asset("assets/icons/ocr.png", width: 38),
                    color: 0xfffff3eb,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 19),
          ActivityTitleWidget(text: "단어장"),
          SizedBox(height: 9),
          ActivityContentWidget(text: "나만의 단어장 만들기", width: 315, height: 108),
        ],
      ),
    );
  }
}
