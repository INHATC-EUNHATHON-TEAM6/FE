import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/activity_content_weight.dart';
import 'package:words_hanjoom/widgets/activity_title_widget.dart';
import 'package:words_hanjoom/widgets/header_widget.dart';
import 'package:words_hanjoom/widgets/navigation_widget.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderWidget(),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ActivityTitleWidget(text: "독해활동"),
            SizedBox(height: 9),

            SizedBox(height: 19),
            ActivityTitleWidget(text: "단어장"),
            SizedBox(height: 19),
            ActivityContentWeight(text: "분야선택"),
          ],
        ),
      ),
      bottomNavigationBar: NavigationWidget(),
    );
  }
}
