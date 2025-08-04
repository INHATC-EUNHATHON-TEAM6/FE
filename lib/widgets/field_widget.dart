import 'package:flutter/material.dart';

class FieldWidget extends StatelessWidget {
  final Image image;
  final String name;
  const FieldWidget({super.key, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 153,
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff3A0B0B)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(top: 1.5), child: image),
          Text(
            name,
            style: TextStyle(
              color: Color(0xff3A0B0B),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
