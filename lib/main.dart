import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:words_hanjoom/screens/record_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String myAccessToken = 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZXN0MDFAdGVzdC5jb20iLCJ1c2VyX2lkIjozLCJhdXRoIjoiIiwiaWF0IjoxNzU2MTM3MTM4LCJleHAiOjE3NTYxNDA3Mzh9.s36QEZttoIMWcg5Q2u0mmd3EYrawG_tLK8XvDXaz2dzNumjxedZ9YM0iidjtjezECgEWPv7jXXO7T-rySruEHQ'; // 실제 토큰 전달!
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      theme: ThemeData(
        fontFamily: 'NotoSansKR',
        scaffoldBackgroundColor: const Color(0xFFF9F7F1),
      ),
      home: RecordPage(accessToken: myAccessToken), // 반드시 토큰 전달!
    );
  }
}
