import 'package:flutter/material.dart';

class NavigationUtils {
  // 단순히 이전 화면으로 돌아가기
  static void back(BuildContext context) {
    Navigator.pop(context);
  }

  // 모든 스택을 지우고 특정 화면으로 이동
  static void clearStackAndNavigateTo(
    BuildContext context,
    Widget destination,
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  // 모든 스택을 지우고 라우트 이름으로 이동
  static void clearStackAndNavigateToNamed(
    BuildContext context,
    String routeName,
  ) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  // 특정 조건까지 스택을 지우고 이동
  static void clearStackUntil(
    BuildContext context,
    Widget destination,
    String untilRoute,
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      ModalRoute.withName(untilRoute),
    );
  }
}
