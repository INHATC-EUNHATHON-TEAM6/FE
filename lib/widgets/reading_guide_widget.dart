import 'package:flutter/material.dart';

class ReadingGuideWidget extends StatefulWidget {
  final bool isTranslating;
  const ReadingGuideWidget({super.key, required this.isTranslating});

  @override
  State<StatefulWidget> createState() => _ReadingGuideWidgetState();
}

class _ReadingGuideWidgetState extends State<ReadingGuideWidget> {
  @override
  Widget build(BuildContext context) {
    String guide = widget.isTranslating
        ? "💡 쉬운 내용으로 번역했습니다.\n번역 내용을 클릭하면 번역 이전 어휘를 확인할 수 있습니다!"
        : "💡 다음 지문을 읽으면서 어려운 어휘가 있으면 그 어휘를 선택하세요. 모두 선택했으면 '쉬운 내용으로 번역' 버튼을 클릭해서 번역된 상태의 지문을 읽어보세요.";

    return Container(
      padding: EdgeInsets.symmetric(vertical: 9.5, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(guide, style: TextStyle(fontSize: 14, letterSpacing: -0.2)),
    );
  }
}
