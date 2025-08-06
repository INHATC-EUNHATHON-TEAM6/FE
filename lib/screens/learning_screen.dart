import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/quiz_screen.dart';
import 'package:words_hanjoom/widgets/button_widget.dart';
import 'package:words_hanjoom/widgets/exit_button_widget.dart';
import 'package:words_hanjoom/widgets/reading_guide_widget.dart';
import 'package:words_hanjoom/widgets/reading_text_widget.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool isTranslating = false;
  late final String passage;

  @override
  void initState() {
    super.initState();
    passage =
        "당신이 퇴근하고 집에 돌아와 저녁 메뉴를 고민하며 냉장고 문을 열었다고 합시다. "
        "어떤 식재료가 있는지 둘러보고는 \"집에 먹을 게 하나도 없네\"라고 중얼거리며 배달 앱을 켜겠지요. "
        "날씨 좋은 주말 아침, 외출하려고 옷장 문을 열었다가 \"입을 옷이 하나도 없군, 옷 좀 사야겠어\"라고 투덜거리며 늘 입던 옷을 입을지도 모릅니다. "
        "냉장고에는 음식이, 옷장에는 옷이 넘쳐나는데 말이지요. "
        "우리에게는 필요하거나 우리가 욕망하는 것은 결코 채워지는 법이 없습니다. "
        "이것을 경제학에서는 '희소성'이라고 합니다. "
        "모든 사람의 욕구를 만족시킬 만큼 자원이 충분하지 않다는 뜻이지요. "
        "경제학은 한마디로 '희소한 자원의 효율적인 분배'를 연구하는 학문입니다. "
        "인간의 욕구는 무한하며 항상 소유하거나 구매할 수 있는 것보다 더 많이 원합니다. "
        "즉 우리는 모두 한정적인 조건에서 여러 선택지를 살피고 평가해 최선의 결정을 내리는 '경제학적 존재'입니다.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f3f3),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            ExitButtonWidget(),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ReadingGuideWidget(isTranslating: isTranslating),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(children: [Expanded(child: ReadingTextWidget())]),
            SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: "쉬운 내용으로 번역",
                    hexColor: 0xfffff2c9,
                    onTap: () {
                      setState(() {
                        isTranslating = true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ButtonWidget(text: "선택 취소", hexColor: 0xffffc9ce),
                ),
              ],
            ),
            SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    text: "퀴즈 시작",
                    hexColor: 0xffc9ffcf,
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  QuizScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = 0.7;
                                const end = 1.0;
                                const curve = Curves.ease;

                                var scaleTween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var scaleAnimation = animation.drive(
                                  scaleTween,
                                );

                                var fadeTween = Tween(
                                  begin: 0.0,
                                  end: 1.0,
                                ).chain(CurveTween(curve: curve));
                                var fadeAnimation = animation.drive(fadeTween);

                                return AnimatedBuilder(
                                  animation: animation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: fadeAnimation.value,
                                      child: Transform.scale(
                                        scale: scaleAnimation.value,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: child,
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
