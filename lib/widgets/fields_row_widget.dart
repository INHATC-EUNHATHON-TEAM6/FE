import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/field_widget.dart';

class FieldsRowWidget extends StatelessWidget {
  final FieldWidget one;
  final FieldWidget? two;
  const FieldsRowWidget({super.key, required this.one, this.two});

  @override
  Widget build(BuildContext context) {
    return Row(children: [one, SizedBox(width: 9), if (two != null) two!]);
  }
}
