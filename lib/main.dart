import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/study_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "NotoSansKR"),
      home: StudyScreen(),
    );
  }
}
