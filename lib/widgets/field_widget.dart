import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/learning_screen.dart';

class FieldWidget extends StatelessWidget {
  final Image image;
  final String name;
  const FieldWidget({super.key, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LearningScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = 0.7;
                  const end = 1.0;
                  const curve = Curves.ease;

                  var scaleTween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var scaleAnimation = animation.drive(scaleTween);

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
      child: Container(
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
      ),
    );
  }
}
