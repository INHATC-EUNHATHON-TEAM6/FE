import 'package:flutter/material.dart';
import '../utils/navigation_utils.dart';

class ExitButtonWidget extends StatelessWidget {
  final String text;
  final Widget? destination;
  final String? routeName;
  final VoidCallback? onTap;

  const ExitButtonWidget({
    super.key,
    required this.text,
    this.destination,
    this.routeName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (destination != null) {
          NavigationUtils.clearStackAndNavigateTo(context, destination!);
        } else if (routeName != null) {
          NavigationUtils.clearStackAndNavigateToNamed(context, routeName!);
        } else {
          NavigationUtils.back(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: Color(0xFFFFF2C9),

          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (destination != null)
              Image.asset("assets/icons/exit.png", width: 18),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: Color(0xff3a0b0b),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
