import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/exit_button_widget.dart';
import 'package:words_hanjoom/widgets/fields_widget.dart';

class FieldsSelectContainerWidget extends StatelessWidget {
  final void Function(String) handleMainScreenWidget;
  final VoidCallback? onFieldSelected;

  const FieldsSelectContainerWidget({
    super.key,
    required this.handleMainScreenWidget,
    this.onFieldSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExitButtonWidget(
              text: "뒤로가기",
              onTap: () {
                handleMainScreenWidget("learning");
              },
            ),
            SizedBox(height: 5),
            Text(
              "분야선택",
              style: TextStyle(
                color: Color(0xff3A0B0B),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 9),
            Text("박종호님이 원하는 분야를 선택하세요!"),
            Text("박종호님의 수준에 맞는 지문으로 독해를 시작합니다."),
            SizedBox(height: 16),
            FieldsWidget(onFieldSelected: onFieldSelected),
          ],
        ),
      ),
    );
  }
}
