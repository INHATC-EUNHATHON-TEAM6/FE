import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/field_widget.dart';
import 'package:words_hanjoom/widgets/fields_row_widget.dart';

class FieldsWidget extends StatelessWidget {
  final List<String> fieldsName = [
    "인문",
    "사회",
    "법률",
    "교육",
    "환경",
    "의학",
    "공학",
    "물리",
    "화학",
    "생명",
    "철학",
    "경제",
  ];
  final Map<String, Image> map = {
    "인문": Image.asset("assets/icons/humanity.png", width: 24),
    "사회": Image.asset("assets/icons/society.png", width: 24),
    "법률": Image.asset("assets/icons/law.png", width: 24),
    "교육": Image.asset("assets/icons/education.png", width: 24),
    "환경": Image.asset("assets/icons/ecosystem.png", width: 24),
    "의학": Image.asset("assets/icons/medicine.png", width: 24),
    "공학": Image.asset("assets/icons/engineering.png", width: 24),
    "물리": Image.asset("assets/icons/physics.png", width: 24),
    "화학": Image.asset("assets/icons/chemistry.png", width: 24),
    "생명": Image.asset("assets/icons/biology.png", width: 24),
    "철학": Image.asset("assets/icons/philosophy.png", width: 24),
    "경제": Image.asset("assets/icons/economy.png", width: 24),
  };
  FieldsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int idx = 0;
    for (idx = 0; idx < fieldsName.length; idx++) {
      if (idx % 2 == 1) {
        children.add(
          FieldsRowWidget(
            one: FieldWidget(
              image: map[fieldsName[idx - 1]]!,
              name: fieldsName[idx - 1],
            ),
            two: FieldWidget(
              image: map[fieldsName[idx]]!,
              name: fieldsName[idx],
            ),
          ),
        );
        children.add(SizedBox(height: 9));
      }
    }
    return Column(children: children);
  }
}
