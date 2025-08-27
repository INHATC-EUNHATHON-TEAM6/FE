import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/record_page.dart';

final Color primaryBrown = Color(0xFF733E17);
final Color bgColor = Color(0xFFFBFAF3);
final Color borderColor = Color(0xFFE0DAD3);

final TextEditingController birthController = TextEditingController();
final TextEditingController careerController = TextEditingController();
final ScrollController _newsScrollController = ScrollController();
final List<String> interestSubjects = [
  '기초•응용과학',
  '신소재•w신기술',
  '항공•우주',
  '생명과학•의학',
  '환경•에너지',
  '경제',
  '고용•복지',
  '금융',
  '산업',
  '사회',
  '문화',
];

List<String> globalUnknownWords = [];
void addUnknownWord(String word) {
  if (!globalUnknownWords.contains(word)) {
    globalUnknownWords.add(word);
  }
}

List<ScrapActivity> allActivities = [];
List<FeedbackSectionData> myFeedbackSections = [];
List<String> myUnknownWords = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(MyApp());
}

// 회원가입 api
Future<bool> registerUser({
  required String loginId,
  required String password,
  required String passwordCheck,
  required String name,
  required String nickname,
  required String birthDate,
  required String careerGoal,
  required List<int> categoryIds,
}) async {
  final url = Uri.parse('http://43.202.149.234:8080/api/auth/signup');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "loginId": loginId,
      "password": password,
      "passwordCheck": passwordCheck,
      "name": name,
      "nickname": nickname,
      "birthDate": birthDate,
      "careerGoal": careerGoal,
      "categoryIds": categoryIds,
    }),
  );

  print('응답 statusCode: ${response.statusCode}');
  print('응답 body: ${response.body}');

  return response.statusCode == 200 || response.statusCode == 201;
}

// 로그인 api
Future<String?> loginUser({
  required String loginId,
  required String password,
}) async {
  final url = Uri.parse('http://43.202.149.234:8080/api/auth/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"loginId": loginId, "password": password}),
  );
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data['token'];
  } else {
    return null;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로그인',
      theme: ThemeData(
        primaryColor: primaryBrown,
        scaffoldBackgroundColor: bgColor,
        fontFamily: 'Pretendard',
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryBrown),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: primaryBrown, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 54),
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryBrown,
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: LogoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => AuthPage()));
    });

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Image.asset('assets/logooooo11.png', width: 232, height: 232),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  List<String> selectedInterests = [];

  List<int> get selectedCategoryIds => selectedInterests
      .map((name) => categoryNameToId[name] ?? 0)
      .where((id) => id != 0)
      .toList();

  final Map<String, int> categoryNameToId = {
    '기초•응용과학': 1,
    '신소재•신기술': 2,
    '항공•우주': 3,
    '생명과학•의학': 4,
    '환경•에너지': 5,
    '경제': 6,
    '고용•복지': 7,
    '금융': 8,
    '산업': 9,
    '사회': 10,
    '문화': 11,
  };
  final pattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{10,20}$',
  );

  bool isLogin = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController pwCheckController = TextEditingController();

  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  //팝업
  void _showAlert(BuildContext context, String message, VoidCallback? onOk) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 12,
        backgroundColor: Colors.white,
        child: Container(
          width: 350,
          padding: EdgeInsets.symmetric(vertical: 42, horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF3A0B0B),
                  fontWeight: FontWeight.w600,
                  fontSize: 21,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 38,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onOk != null) onOk();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: 1,
                    ),
                  ),
                  child: Text("확인"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() async {
    final loginId = emailController.text.trim();
    final password = passwordController.text;

    if (isLogin) {
      if (loginId.isEmpty && password.isEmpty) {
        _showAlert(context, '아이디와 비밀번호를\n 입력하지 않았습니다.', null);
        return;
      }
      if (loginId.isEmpty) {
        _showAlert(context, '아이디(이메일)를\n 입력하지 않았습니다.', null);
        return;
      }
      if (password.isEmpty) {
        _showAlert(context, '비밀번호를\n 입력하지 않았습니다.', null);
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Future.delayed(Duration(seconds: 2)); //로딩 딜레이
        if (isLogin) {
          final token = await loginUser(loginId: loginId, password: password);
          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('access_token', token);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainPage()),
            );
          } else {
            _showAlert(context, '로그인 실패: 아이디 또는 비밀번호를 확인하세요.', null);
          }
        } else {
          final success = await registerUser(
            loginId: loginId,
            password: password,
            passwordCheck: pwCheckController.text,
            name: nameController.text,
            nickname: nicknameController.text,
            birthDate: birthController.text,
            careerGoal: careerController.text,
            categoryIds: selectedCategoryIds,
          );
          if (success) {
            _showAlert(context, '회원가입 성공! 이제 로그인 하세요.', null);
            setState(() => isLogin = true);
          } else {
            _showAlert(context, '회원가입 실패: \n입력값을 확인하세요.', null);
          }
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 8, right: 8, top: 1),
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100, bottom: 40),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/logooooo11.png',
                                width: 200,
                                height: 200,
                              ),
                              if (!isLogin) ...[
                                Image.asset('assets/lgn.png', width: 200),
                              ],
                            ],
                          ),
                        ),
                      ),

                      _Label('아이디(Email)', required: true),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFEEEFEF),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFFE3E3E3),
                              width: 1.7,
                            ),
                          ),
                          hintText: '아이디를 입력하세요.',
                          hintStyle: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        validator: (v) {
                          if (v == null || v.isEmpty) return '이메일을 입력해 주세요';
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v))
                            return '이메일 형식이 올바르지 않아요';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _Label('비밀번호', required: true),
                      SizedBox(height: 6),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFEEEFEF),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFFE3E3E3),
                              width: 1.7,
                            ),
                          ),
                          hintText: '비밀번호를 입력하세요.',
                          hintStyle: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 10)
                            return '숫자, 영어 대소문자, 특수문자를 각 1자 이상을 포함한\n10자~20자의 비밀번호를 입력하세요.';
                          if (v.length > 20) {
                            return '비밀번호는 10자 이상 20자 이하여야 합니다.';
                          }
                          if (!pattern.hasMatch(v)) {
                            return '숫자, 대문자, 소문자, 특수문자를 모두 포함해야 합니다.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      if (!isLogin) ...[
                        _Label('비밀번호 확인', required: true),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: pwCheckController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEEEFEF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE3E3E3),
                                width: 1.7,
                              ),
                            ),
                            hintText: '비밀번호를 다시 입력하세요',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return '이전에 입력한 비밀번호를 한 번 더 입력하세요.';
                            if (v != passwordController.text)
                              return '비밀번호가 일치하지 않습니다';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _Label('닉네임', required: true),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: nicknameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEEEFEF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE3E3E3),
                                width: 1.7,
                              ),
                            ),
                            hintText: '닉네임을 입력하세요.',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return '닉네임을 입력해 주세요';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _Label('이름', required: true),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEEEFEF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE3E3E3),
                                width: 1.7,
                              ),
                            ),
                            hintText: '이름을 입력하세요.',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return '이름을 입력해 주세요';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _Label('생년월일', required: true),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: birthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEEEFEF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE3E3E3),
                                width: 1.7,
                              ),
                            ),
                            hintText: '생년월일을 입력하세요',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'YYYY-MM-DD 형식으로 입력하세요.';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _Label('관심진로', required: true),
                        SizedBox(height: 6),
                        TextFormField(
                          controller: careerController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFEEEFEF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color(0xFFE3E3E3),
                                width: 1.7,
                              ),
                            ),
                            hintText: '관심진로를 입력하세요',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return '관심진로를 입력하세요.';
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _Label('관심 분야', required: true),
                        SizedBox(height: 3),
                        Wrap(
                          spacing: 3,
                          runSpacing: -5,
                          children: interestSubjects.map((subject) {
                            final isSelected = selectedInterests.contains(
                              subject,
                            );
                            return FilterChip(
                              label: Text(subject),
                              selected: isSelected,
                              selectedColor: Color(0xFFFFE89E),
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.black : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedInterests.add(subject);
                                  } else {
                                    selectedInterests.remove(subject);
                                  }
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 35),
                      ],
                      ElevatedButton(
                        onPressed: _isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 54),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        child: Text(
                          _isLoading
                              ? (isLogin ? '로그인 중 ...' : '회원가입 처리 중 ...')
                              : (isLogin ? '로그인' : '회원가입 완료'),
                        ),
                      ),

                      SizedBox(height: 10),
                      Center(
                        child: OutlinedButton(
                          onPressed: toggle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: primaryBrown, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(double.infinity, 54),
                          ),
                          child: Text(
                            isLogin ? '회원가입' : '이미 계정이 있나요? 로그인',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: primaryBrown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.65),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.brown[100]?.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final bool required;
  const _Label(this.label, {this.required = false});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.brown,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontFamily: 'notosans.ttf',
        ),
        children: required
            ? [
                TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}

//메인페이지
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<String> get unknownWords => globalUnknownWords;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy년 M월 d일', 'ko_KR').format(now);
    // 디버그용 코드로 사용 가능한 폰트 확인
    debugPrint(
      'Available fonts: ${Theme.of(context).textTheme.bodyLarge?.fontFamily}',
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontFamily: 'Jalnan2',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                children: [
                  // 카드 1
                  Card(
                    color: const Color(0xFFFFFBDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 210,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '신문 스크랩 활동',
                                  style: TextStyle(
                                    fontFamily: 'Jalnan2',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF733E17),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '관심 있는 분야의 기사를 스크랩 하고\n나만의 뉴스 아카이브를 만들어보세요.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontFamily: 'Pretendard',
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Image.asset(
                                    'assets/news_icon.png',
                                    width: 114,
                                    height: 114,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ScrapActivityPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFBC3A5),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 13,
                                  ),
                                  minimumSize: Size(140, 36),
                                ),
                                child: Text(
                                  '시작하기',
                                  style: TextStyle(
                                    color: Color(0xFF733E17),
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Pretendard',
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // 카드 2
                  Card(
                    color: const Color(0xFFFFFBDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '단어장',
                                  style: TextStyle(
                                    fontFamily: 'Jalnan2',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF733E17),
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  '기사를 읽으며 알게 된\n새로운 단어나 표현을 저장하고,\n뜻과 예문까지 함께 정리해 익혀 보세요.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontFamily: 'Pretendard',
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),

                            Positioned(
                              top: -18,
                              right: 0,
                              child: Image.asset(
                                'assets/book_icon.png',
                                width: 106,
                                height: 106,
                                fit: BoxFit.contain,
                              ),
                            ),

                            Positioned(
                              right: 2,
                              bottom: 0,
                              child: Material(
                                color: Color(0xFFFBC3A5),
                                borderRadius: BorderRadius.circular(30),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WordbookPage(
                                          unknownWords: List<String>.from(
                                            globalUnknownWords,
                                          ),
                                        ),
                                      ),
                                    );
                                    setState(() {}); //화면갱신!
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(9),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF733E17),
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  // 카드 3
                  Card(
                    color: const Color(0xFFFFFBDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 120,
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text(
                                  '스크랩 활동 기록',
                                  style: TextStyle(
                                    fontFamily: 'Jalnan2',
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF733E17),
                                  ),
                                ),
                                SizedBox(height: 7),
                                Text(
                                  '스크랩한 기사와 단어, 작성한 생각 등\n활동 내역을 날짜별로 확인해 보세요.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontFamily: 'Pretendard',
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Image.asset(
                                'assets/clipboard_icon.png',
                                width: 69,
                                height: 69,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              right: 1,
                              bottom: 0,
                              child: Material(
                                color: Color(0xFFFBC3A5),
                                borderRadius: BorderRadius.circular(30),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),

                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final token =
                                        prefs.getString('access_token') ?? '';
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RecordPage(accessToken: token),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(9),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF733E17),
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//스크랩 api
Future<Map<String, dynamic>?> fetchArticle(String userToken) async {
  final url = Uri.parse('http://43.202.149.234:8080/api/scrap-news/pick-one');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"userToken": userToken}),
  );
  print('API status: ${response.statusCode}, body: ${response.body}');
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data;
  }
  return null;
}

//스크랩
class ScrapActivityPage extends StatefulWidget {
  const ScrapActivityPage({super.key});

  @override
  State<ScrapActivityPage> createState() => _ScrapActivityPageState();
}

class _ScrapActivityPageState extends State<ScrapActivityPage> {
  Map<String, dynamic>? article;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadArticle();
  }

  Future<void> loadArticle() async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('access_token') ?? "";
    if (!mounted) return;
    if (userToken.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final data = await fetchArticle(userToken);
    if (!mounted) return;
    setState(() {
      article = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          backgroundColor: const Color(0xFFF6F1EB),
          elevation: 0,
          titleSpacing: 0,
          leadingWidth: 120,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15, top: 14, bottom: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBC1),
                elevation: 4,
                shadowColor: Colors.grey.withOpacity(1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 0),
                minimumSize: Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.home_outlined,
                color: Color(0xFF733E17),
                size: 22,
              ),
              label: Text(
                '나가기',
                style: TextStyle(
                  color: Color(0xFF3A0B0B),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 0,
                  fontFamily: 'notosans',
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2, top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(1),
                    blurRadius: 7,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: Text(
                      "💡뉴스를 읽은 뒤 ‘스크랩 활동하기’ 버튼을 눌러 주요 내용과\n 자신의 생각을 작성하세요. 작성 후 제공되는 AI 피드백으로 학습\n 능력을 항상 시킬 수 있습니다.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.1,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      blurRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (article == null
                          ? Center(child: Text("기사를 불러올 수 없습니다."))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (article?['content'] != null)
                                    Text(
                                      article!['content'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                ],
                              ),
                            )),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(bottom: 90, top: 0),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: ElevatedButton(
                  onPressed: article == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CrollingPage(
                                newsText: article!['content'] ?? '',
                                articleId: article?['articleId'] ?? 0,
                                articleTitle: article?['title'] ?? '',
                              ),
                            ),
                          );
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF733E17),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      letterSpacing: -0.5,
                    ),
                  ),
                  child: const Text("스크랩 활동하기"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//기사 크롤링

class CrollingPage extends StatefulWidget {
  final String newsText;
  final int articleId;
  final String articleTitle;

  CrollingPage({
    Key? key,
    required this.newsText,
    required this.articleId,
    required this.articleTitle,
  }) : super(key: key);

  @override
  _CrollingPageState createState() => _CrollingPageState();
}

class _CrollingPageState extends State<CrollingPage> {
  final Color brown = const Color(0xFF3A0B0B);

  final TextEditingController fieldController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();
  final TextEditingController opinionController = TextEditingController();
  final TextEditingController keywordInputController = TextEditingController();
  final TextEditingController wordInputController = TextEditingController();

  List<String> keywords = [];
  List<String> words = [];

  void onScrapComplete(BuildContext context) {
    final newActivity = ScrapActivity(
      category: fieldController.text,
      order:
          allActivities
              .where(
                (a) =>
                    a.activityDateTime.year == DateTime.now().year &&
                    a.activityDateTime.month == DateTime.now().month &&
                    a.activityDateTime.day == DateTime.now().day,
              )
              .length +
          1,
      activityDateTime: DateTime.now(),
      title: titleController.text,
      content: widget.newsText,
      summary: summaryController.text,
      opinion: opinionController.text,
      keywords: List<String>.from(keywords),
      unknownWords: List<String>.from(words),
      articleId: widget.articleId,
    );
    allActivities.add(newActivity);
  }

  @override
  void initState() {
    super.initState();
  }

  void addKeyword(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !keywords.contains(trimmed)) {
      setState(() {
        keywords.add(trimmed);
      });
    }
    keywordInputController.clear();
  }

  void addWord(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !words.contains(trimmed)) {
      setState(() {
        words.add(trimmed);
        addUnknownWord(trimmed);
      });
    }
    wordInputController.clear();
  }

  void removeKeyword(int idx) {
    setState(() {
      keywords.removeAt(idx);
    });
  }

  void removeWord(int idx) {
    setState(() {
      words.removeAt(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> myKeywords = keywords;
    List<String> modelKeywords = ["주식", "투자", "시장", "경제성장", "금리정책"];
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          titleSpacing: 0,
          leadingWidth: 120,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15, top: 14, bottom: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFEBC1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: Colors.grey.withOpacity(1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 0,
                ),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(Icons.home, color: Color(0xFF733E17), size: 22),
              label: Text(
                '나가기',
                style: TextStyle(
                  color: Color(0xFF733E17),
                  fontWeight: FontWeight.w900,
                  fontSize: 16.2,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 13, top: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(
                      child: Text(
                        "💡뉴스를 읽은 뒤 ‘스크랩 활동하기’ 버튼을 눌러 주요 내용과\n 의견을 작성하세요. 작성 후 제공되는 AI 피드백으로 학습 능력을\n 항상 시킬 수 있습니다.",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'notosans',
                          color: Colors.black,
                          height: 1,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 2, color: Color(0xFF3A0B0B)),
                        ),
                      ),
                      child: Text(
                        "스크랩 활동",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF3A0B0B),
                          fontFamily: 'Pretendard',
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              _scrapTextField(
                label: "분야 (예: 경제, 환경)",
                controller: fieldController,
                brown: Color(0xFF3A0B0B),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                margin: const EdgeInsets.only(bottom: 13),
                labelBold: true,
              ),
              _scrapTextField(
                label: "제목 (기사 내용에 어울리는 제목을 작성하세요.)",
                controller: titleController,
                brown: Color(0xFF3A0B0B),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                margin: const EdgeInsets.only(bottom: 13),
                labelBold: true,
              ),
              _tagInputField(
                label: "주요 키워드 (기사의 주요 키워드를 작성하세요.)",
                controller: keywordInputController,
                brown: Color(0xFF3A0B0B),
                tags: keywords,
                onAdd: addKeyword,
                onDelete: removeKeyword,
                labelBold: true,
              ),
              _tagInputField(
                label: "모르는 어휘 (어휘들은 단어장에서 확인 할 수 있습니다.)",
                controller: wordInputController,
                brown: Color(0xFF3A0B0B),
                tags: words,
                onAdd: addWord,
                onDelete: removeWord,
                labelBold: true,
              ),
              _scrapTextField(
                label: "기사 요약",
                controller: summaryController,
                brown: Color(0xFF3A0B0B),
                minLines: 5,
                maxLines: 5,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 13),
                labelBold: true,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "기사에 대한 자신의 생각",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'notosans',
                        fontSize: 15,
                        color: Color(0xFF3A0B0B),
                        height: 2.18,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 0, bottom: 0),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.4,
                        ),
                      ),
                      child: TextField(
                        minLines: 7,
                        maxLines: 7,
                        controller: opinionController,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: 295,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final summaryText = summaryController.text.trim();
                      final fieldText = fieldController.text.trim();
                      final titleText = titleController.text.trim();
                      final opinionText = opinionController.text.trim();
                      final newActivity = ScrapActivity(
                        category: fieldText,
                        order:
                            allActivities
                                .where(
                                  (a) =>
                                      a.activityDateTime.year ==
                                          DateTime.now().year &&
                                      a.activityDateTime.month ==
                                          DateTime.now().month &&
                                      a.activityDateTime.day ==
                                          DateTime.now().day,
                                )
                                .length +
                            1,
                        activityDateTime: DateTime.now(),
                        title: titleText,
                        content: widget.newsText,
                        summary: summaryText,
                        opinion: opinionText,
                        keywords: List<String>.from(keywords),
                        unknownWords: List<String>.from(words),
                        articleId: widget.articleId,
                      );
                      allActivities.add(newActivity);

                      if (fieldController.text.trim().isEmpty) {
                        showAlertDialog(context, '분야를 입력하지\n 않았습니다.');
                        return;
                      }
                      if (titleController.text.trim().isEmpty) {
                        showAlertDialog(context, '제목을 입력하지\n 않았습니다.');
                        return;
                      }
                      if (keywords.isEmpty) {
                        showAlertDialog(context, '주요 키워드를 입력하지\n 않았습니다.');
                        return;
                      }
                      if (summaryController.text.trim().isEmpty) {
                        showAlertDialog(context, '기사 요약을 입력하지\n 않았습니다.');
                        return;
                      }
                      if (opinionController.text.trim().isEmpty) {
                        showAlertDialog(
                          context,
                          '기사에 대한 자신의 생각을\n 입력하지 않았습니다.',
                        );
                        return;
                      }

                      showSuccessDialog(
                        context,
                        newsText: widget.newsText,
                        summary: summaryText,
                        field: fieldText,
                        title: titleText,
                        keywords: keywords,
                        unknownWords: words,
                        myKeywords: myKeywords,
                        modelKeywords: modelKeywords,
                        opinion: opinionText,
                        articleId: widget.articleId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      shadowColor: Colors.grey.withOpacity(1),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'notosans',
                        fontSize: 19,
                        letterSpacing: -0.1,
                      ),
                    ),
                    child: const Text("스크랩 활동 완료"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scrapTextField({
    required String label,
    required TextEditingController controller,
    required Color brown,
    bool labelBold = false,
    int minLines = 1,
    int maxLines = 1,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 13,
    ),
    EdgeInsetsGeometry? margin,
  }) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customLabel(label, brown),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1.4),
            ),
            child: TextField(
              minLines: minLines,
              maxLines: maxLines,
              controller: controller,
              decoration: InputDecoration(
                contentPadding: contentPadding,
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget customLabel(String label, Color color) {
    final match = RegExp(r'^(.+?)(\s*\(.+\))$').firstMatch(label);
    if (match != null) {
      final main = match.group(1)!.trim();
      final bracket = match.group(2)!;
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: main,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 17,
                height: 1.0,
                fontFamily: 'notosans',
              ),
            ),
            TextSpan(
              text: bracket,
              style: TextStyle(
                color: Color(0xFF3A0B0B),
                fontWeight: FontWeight.w700,
                fontFamily: 'notosans',
                fontSize: 13,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w900,
        fontSize: 17,
        height: 1.0,
      ),
    );
  }

  Widget _tagInputField({
    required String label,
    required TextEditingController controller,
    required Color brown,
    required List<String> tags,
    required void Function(String) onAdd,
    required void Function(int) onDelete,
    bool labelBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customLabel(label, brown),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1.4),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: onAdd,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 20,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 0),
            child: Wrap(
              spacing: 3,
              children: List.generate(tags.length, (idx) {
                return Container(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 20,
                    maxWidth: 196,
                  ),
                  padding: const EdgeInsets.fromLTRB(7, 5, 13, 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryBrown, width: 1.1),
                    borderRadius: BorderRadius.circular(11),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => onDelete(idx),
                        child: Icon(
                          Icons.cancel_rounded,
                          color: primaryBrown,
                          size: 10,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          tags[idx],
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3A0B0B),
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

void showAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 14),
      elevation: 12,
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4D2C13),
              fontWeight: FontWeight.w600,
              fontSize: 21,
              height: 1.3,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(0, 37),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('확인', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    ),
  );
}

String userTypeStringToCode(String eval) {
  final parts = eval.split(';');
  if (parts.length != 4) return eval;
  String code = "";
  for (int i = 0; i < 4; i++) {
    int? num = int.tryParse(parts[i].trim());
    if (num == null) return eval;
    switch (i) {
      case 0:
        code += (num >= 5) ? 'O' : 'S';
        break;
      case 1:
        code += (num >= 5) ? 'A' : 'I';
        break;
      case 2:
        code += (num >= 5) ? 'C' : 'P';
        break;
      case 3:
        code += (num >= 5) ? 'T' : 'N';
        break;
    }
  }
  return code;
}

void showSuccessDialog(
  BuildContext context, {
  required String summary,
  required String newsText,
  required String field,
  required String title,
  required List<String> keywords,
  required List<String> unknownWords,
  required List<String> myKeywords,
  required List<String> modelKeywords,
  required String opinion,
  required int articleId,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.symmetric(vertical: 42, horizontal: 14),
      elevation: 12,
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "스크랩 완료🎉",
                  style: TextStyle(
                    color: primaryBrown,
                    fontWeight: FontWeight.w900,
                    fontSize: 25,
                    fontFamily: 'notosans',
                  ),
                ),
                TextSpan(
                  text: " \n\n입력하신 내용을 바탕으로 피드백이 제공됩니다.",
                  style: TextStyle(
                    color: Color(0xFF4D2C13),
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(0, 37),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('access_token') ?? '';

                final feedback = await requestFeedback(
                  accessToken: token,
                  articleId: articleId,
                  category: field,
                  title: title,
                  keywords: keywords,
                  vocabularies: unknownWords,
                  summary: summary,
                  comment: opinion,
                );
                print('==requestFeedback 반환값: $feedback');
                print('AI 피드백에 보낸 articleId: $articleId');

                List<FeedbackSectionData> feedbackSections = [];
                if (feedback != null && feedback['feedbacks'] != null) {
                  for (final fb in feedback['feedbacks']) {
                    print('Received activityType: ${fb['activityType']}');
                    final type = (fb['activityType'] ?? '')
                        .toString()
                        .toUpperCase();
                    String? titleStr;
                    switch (type) {
                      case 'CATEGORY':
                        titleStr = "기사 분야 파악하기";
                        break;
                      case 'TITLE':
                        titleStr = "기사 제목 파악하기";
                        break;
                      case 'KEYWORD':
                        titleStr = "주요 키워드 찾기";
                        break;
                      case 'SUMMARY':
                        titleStr = "요약하기";
                        break;
                      case 'THOUGHT_SUMMARY':
                        titleStr = "자신의 생각 키우기";
                        break;
                      default:
                        titleStr = null;
                    }
                    if (titleStr != null) {
                      feedbackSections.add(
                        FeedbackSectionData(
                          title: titleStr,
                          myAnswer: fb['userAnswer'] ?? "",
                          modelAnswer: fb['aiAnswer'] ?? "",
                          feedback: fb['aiFeedback'] ?? "",
                          score: fb['evaluationScore'] != null
                              ? double.tryParse(
                                  fb['evaluationScore'].toString(),
                                )
                              : null,
                          similarityScore: fb['similarityScore'] != null
                              ? double.tryParse(
                                  fb['similarityScore'].toString(),
                                )
                              : null,
                          evaluationScore: fb['evaluationScore']?.toString(),
                        ),
                      );
                    }
                    print('Added section with title: $titleStr');
                  }
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiFeedbackPage(
                      newsText: newsText,
                      feedbackSections: feedbackSections,
                      unknownWords: unknownWords,
                      userSummary: summary,
                      userOpinion: opinion,
                    ),
                  ),
                );
              },
              child: Text(
                'AI 피드백 받기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// 스크랩 활동 피드백

class AiFeedbackPage extends StatelessWidget {
  final String newsText; // 뉴스 지문
  final List<String> unknownWords;
  final List<FeedbackSectionData> feedbackSections;
  final String userSummary;
  final String userOpinion;

  final String? modelSummary;
  final String? feedbackSummary;
  final String? modelOpinion;
  final String? feedbackOpinion;

  const AiFeedbackPage({
    Key? key,
    required this.newsText,
    required this.feedbackSections,
    required this.unknownWords,
    required this.userSummary,
    required this.userOpinion,
    this.modelSummary,
    this.feedbackSummary,
    this.modelOpinion,
    this.feedbackOpinion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? userType;
    for (final section in feedbackSections) {
      if (section.title == "자신의 생각 키우기" && section.userType != null) {
        userType = section.userType;
        break;
      }
    }
    List<Widget> feedbackWidgets = [];

    for (final section in feedbackSections) {
      String? extraBadge;

      switch (section.title) {
        case "기사 분야 파악하기":
        case "기사 제목 파악하기":
        case "주요 키워드 찾기":
          if (section.similarityScore != null) {
            extraBadge =
                '의미 유사도: ${(section.similarityScore! * 100).toStringAsFixed(0)}%';
          } else if (section.score != null) {
            extraBadge =
                '의미 유사도: ${(section.score! * 100).toStringAsFixed(0)}%';
          }
          break;
        case "요약하기":
          if (section.score != null)
            extraBadge = '요약 점수: ${(section.score! * 100).toStringAsFixed(0)}%';
          break;
        case "자신의 생각 키우기":
          if (section.evaluationScore != null &&
              section.evaluationScore!.contains(';')) {
            extraBadge =
                '사용자 유형: ${userTypeStringToCode(section.evaluationScore!)}';
          } else if (section.evaluationScore != null) {
            extraBadge = '사용자 유형: ${section.evaluationScore!}';
          }
          break;
      }
      feedbackWidgets.add(
        FeedbackSectionCard(
          title: section.title,
          myAnswer: section.myAnswer,
          modelAnswer: section.modelAnswer,
          feedback: section.feedback,
          similarityScore: section.similarityScore,
          extraBadge: extraBadge,
        ),
      );

      if (section.title == "주요 키워드 찾기") {
        feedbackWidgets.add(UnknownWordsCard(words: unknownWords));
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF733E17),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '스크랩 활동 피드백',
          style: TextStyle(color: Colors.white, fontFamily: 'Jalnan2'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showGoMainMenuDialog(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 뉴스 지문
            feedbackNewsSection(newsText),

            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(17, 8, 17, 5),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFDD94),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '스크랩 활동',
                      style: TextStyle(
                        color: primaryBrown,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        fontFamily: 'Jalnan2',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  ...feedbackWidgets,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//피드백페이지 뉴스지문
Widget feedbackNewsSection(String newsText) {
  const double scrollbarThickness = 8;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 15),
      Container(
        padding: EdgeInsets.fromLTRB(17, 8, 17, 5),
        decoration: BoxDecoration(
          color: Color(0xFFFFDD94),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '뉴스 지문',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            fontFamily: 'Jalnan2',
            letterSpacing: -0.5,
          ),
        ),
      ),
      SizedBox(height: 10),
      Container(
        width: double.infinity,
        height: 500,
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.fromLTRB(17, 15, 17, 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xFFE0DAD3), width: 1),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: SingleChildScrollView(
                controller: _newsScrollController,
                child: Text(
                  newsText,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: Colors.black87,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _KeywordChip extends StatelessWidget {
  final String text;
  const _KeywordChip({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF733E17), width: 1.1),
        borderRadius: BorderRadius.circular(11),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF733E17),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class UnknownWordsCard extends StatelessWidget {
  final List<String> words;
  const UnknownWordsCard({Key? key, required this.words}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Color(0xFFE0DAD3), width: 1),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '모르는 어휘 목록',
              style: TextStyle(
                fontFamily: 'Jalnan2',
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: primaryBrown,
              ),
            ),
            SizedBox(height: 16),
            words.isEmpty
                ? Text('없음', style: TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    children: words.map((w) => _KeywordChip(text: w)).toList(),
                  ),
            SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordbookPage(
                        unknownWords: List<String>.from(globalUnknownWords),
                        fromFeedback: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF733E17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "단어장에서 확인하기",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSectionCardCustom extends StatelessWidget {
  final String title;
  final String userText;
  final String modelText;
  final String feedbackText;
  final String? extraBadge;

  const _FeedbackSectionCardCustom({
    Key? key,
    required this.title,
    required this.userText,
    required this.modelText,
    required this.feedbackText,
    this.extraBadge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: const Color(0xFFE0DAD3), width: 1),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Jalnan2',
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: primaryBrown,
                  ),
                ),
                if (extraBadge != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE093),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      extraBadge!,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Color(0xFF856320),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            _LabelAnswerBlock(
              label: '내 답변',
              value: userText,
              labelBg: Colors.white,
              valueBg: Color(0xFFD9EDFF),
              labelTextColor: Color(0xFF715729),
              valueTextColor: Colors.black,
            ),
            if (modelText.isNotEmpty) ...[
              SizedBox(height: 13),
              _LabelAnswerBlock(
                label: '모범 답변',
                value: modelText,
                labelBg: Color(0xFFCBF8C9),
                valueBg: Color(0xFFD9FFE3),
                labelTextColor: Color(0xFF30824A),
                valueTextColor: Colors.black,
              ),
            ],
            SizedBox(height: 13),
            _LabelAnswerBlock(
              label: '피드백',
              value: feedbackText,
              labelBg: Color(0xFFFFEEC1),
              valueBg: Color(0xFFFFF0D9),
              labelTextColor: Color(0xFF715729),
              valueTextColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackSectionData {
  final String title;
  final String myAnswer;
  final String modelAnswer;
  final String feedback;
  final double? score;
  final double? similarityScore;
  final String? evaluationScore;
  final String? userType;

  FeedbackSectionData({
    required this.title,
    required this.myAnswer,
    required this.modelAnswer,
    required this.feedback,
    this.score,
    this.similarityScore,
    this.userType,
    this.evaluationScore,
  });
}

class FeedbackSectionCard extends StatelessWidget {
  final String title;
  final String myAnswer;
  final String modelAnswer;
  final String feedback;
  final double? similarityScore;
  final String? extraBadge;

  const FeedbackSectionCard({
    super.key,
    required this.title,
    required this.myAnswer,
    required this.modelAnswer,
    required this.feedback,
    this.similarityScore,
    this.extraBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),

      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFE0DAD3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  의미 유사도
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Jalnan2',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF733E17),
                  fontSize: 18,
                ),
              ),
              if (extraBadge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE093),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    extraBadge!,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Jalnan2',
                      fontSize: 9,
                      color: primaryBrown,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          _LabelAnswerBlock(
            label: '내 답변',
            value: myAnswer,
            labelBg: Colors.white,
            valueBg: Color(0xFFD9EDFF),
            labelTextColor: Color(0xFF715729),
            valueTextColor: Colors.black,
          ),
          SizedBox(height: 13),
          if (modelAnswer.isNotEmpty) ...[
            _LabelAnswerBlock(
              label: '모범 답변',
              value: modelAnswer,
              labelBg: Color(0xFFCBF8C9),
              valueBg: Color(0xFFD9FFE3),
              labelTextColor: Color(0xFF30824A),
              valueTextColor: Colors.black,
            ),
          ],
          SizedBox(height: 13),
          _LabelAnswerBlock(
            label: '피드백',
            value: feedback,
            labelBg: Color(0xFFFFEEC1),
            valueBg: Color(0xFFFFF0D9),
            labelTextColor: Color(0xFF715729),
            valueTextColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

class _LabelAnswerBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color labelBg;
  final Color valueBg;
  final Color labelTextColor;
  final Color valueTextColor;

  const _LabelAnswerBlock({
    required this.label,
    required this.value,
    required this.labelBg,
    required this.valueBg,
    required this.labelTextColor,
    required this.valueTextColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
          decoration: BoxDecoration(
            color: labelBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFD6D6D6), width: 0.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: labelTextColor,
            ),
          ),
        ),
        SizedBox(height: 7),
        Container(
          width: double.infinity,
          padding: label == '피드백'
              ? EdgeInsets.symmetric(horizontal: 16, vertical: 60)
              : EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          constraints: label == '피드백'
              ? BoxConstraints(minHeight: 100)
              : BoxConstraints(),
          decoration: BoxDecoration(
            color: valueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: valueTextColor),
          ),
        ),
      ],
    );
  }
}

// 네 아니요 팝업
void showGoMainMenuDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 75, 15, 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "메인메뉴로 이동합니다.",
              style: TextStyle(
                color: Color(0xFF3A0B0B),
                fontWeight: FontWeight.w700,
                fontSize: 21,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 네 버튼
                SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 닫기
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => MainPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF733E17),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                      ),
                      elevation: 2,
                    ),
                    child: Text('네'),
                  ),
                ),
                SizedBox(width: 5),
                // 아니요 버튼
                SizedBox(
                  width: 90,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 그냥 닫기
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFFFFF6DF),
                      foregroundColor: primaryBrown,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    child: Text('아니요'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

//피드백 api
Future<Map<String, dynamic>?> requestFeedback({
  required String accessToken,
  required int articleId,
  required String category,
  required String title,
  required List<String> keywords,
  required List<String> vocabularies,
  required String summary,
  required String comment,
}) async {
  final url = Uri.parse('http://43.202.149.234:8080/api/feedback');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      "articleId": articleId,
      "category": category,
      "title": title,
      "keywords": keywords,
      "vocabularies": vocabularies,
      "summary": summary,
      "comment": comment,
    }),
  );
  print('AI 피드백 응답: ${response.statusCode}');
  print('AI 피드백 body: ${response.body}');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> fetchFeedbackDetail({
  required String accessToken,
  required int articleId,
}) async {
  final url = Uri.parse('http://43.202.149.234:8080/api/feedback/$articleId');
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> fetchMonthlyActivity({
  required String accessToken,
  required int year,
  required int month,
}) async {
  final url = Uri.parse(
    'http://43.202.149.234:8080/api/feedback/list?year=$year&month=$month',
  );
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

class VocabWord {
  final int? wordId;
  final String word;
  String? meaning;
  String field;
  String? example;
  String? synonym;
  String? antonym;
  bool isExpanded;
  bool isLoading;
  bool isError;

  VocabWord({
    this.wordId,
    required this.word,
    this.meaning,
    this.field = '없음',
    this.example,
    this.synonym,
    this.antonym,
    this.isExpanded = false,
    this.isLoading = false,
    this.isError = false,
  });
}

class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dotWidth;
  final double space;
  final double strokeWidth;

  const DottedLine({
    this.height = 1,
    this.color = const Color(0xFFE0DAD3),
    this.dotWidth = 2,
    this.space = 1,
    this.strokeWidth = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DottedLinePainter(
          color: color,
          dotWidth: dotWidth,
          space: space,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotWidth;
  final double space;
  final double strokeWidth;

  _DottedLinePainter({
    required this.color,
    this.dotWidth = 4,
    this.space = 3,
    this.strokeWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    while (startX < size.width) {
      final endX = startX + dotWidth;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX.clamp(0, size.width), size.height / 2),
        paint,
      );
      startX += dotWidth + space;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WordbookPage extends StatefulWidget {
  final List<String> unknownWords;
  final bool fromFeedback;

  const WordbookPage({
    Key? key,
    required this.unknownWords,
    this.fromFeedback = false,
  }) : super(key: key);

  @override
  State<WordbookPage> createState() => _WordbookPageState();
}

class _WordbookPageState extends State<WordbookPage> {
  List<VocabWord> wordList = [];
  late List<String> localWords; //

  List<VocabWord> globalWordbook = [];

  //중복방지
  void addUnknownWordsToWordbook(List<String> newWords) {
    for (var word in newWords) {
      if (!globalWordbook.any((w) => w.word == word)) {
        globalWordbook.add(VocabWord(word: word, isLoading: true));
      }
    }
  }

  late Future<List<WordItemDto>> wordbookFuture;
  int page = 0;
  int size = 20;

  @override
  void initState() {
    super.initState();
    loadWordbook();
    localWords = List<String>.from(widget.unknownWords);
    for (final w in localWords) {
      if (!globalUnknownWords.contains(w)) {
        globalUnknownWords.add(w);
      }
    }
    wordList = localWords.map((w) => VocabWord(word: w)).toList();
  }

  Future<void> loadWordbook() async {
    List<WordItemDto> items = await fetchWordbook();
    setState(() {
      wordList = items.map((dto) => fromWordItemDto(dto)).toList();
    });
  }

  @override
  void didUpdateWidget(covariant WordbookPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unknownWords != widget.unknownWords) {
      setState(() {
        localWords = List<String>.from(widget.unknownWords);
        for (final w in localWords) {
          if (!globalUnknownWords.contains(w)) {
            globalUnknownWords.add(w);
          }
        }
        wordList = localWords.map((w) => VocabWord(word: w)).toList();
      });
    }
  }

  void addUnknownWord(String word) {
    if (!globalUnknownWords.contains(word)) {
      globalUnknownWords.add(word);
    }
  }

  Future<void> fetchMeanings() async {
    for (int i = 0; i < wordList.length; i++) {
      setState(() {
        wordList[i].isLoading = true;
        wordList[i].isError = false;
      });

      try {} catch (e) {
        wordList[i].meaning = null;
        wordList[i].isError = true;
      }

      setState(() {
        wordList[i].isLoading = false;
      });
    }
  }

  void removeWord(int idx) {
    setState(() {
      String removed = localWords.removeAt(idx);
      globalUnknownWords.remove(removed);
    });
  }

  void toggleExpand(int idx) {
    setState(() {
      wordList[idx].isExpanded = !wordList[idx].isExpanded;
    });
  }

  Future<bool> _onWillPop() async {
    if (widget.fromFeedback) {
      return true;
    } else {
      showGoMainMenuDialog(context);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Colors.white;
    final Color borderColor = Color(0xFFE0DAD3);
    final Color primaryBrown = Color(0xFF733E17);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: primaryBrown,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          title: Text(
            '단어장',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Jalnan2',
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: 43),
            onPressed: () {
              if (widget.fromFeedback) {
                Navigator.of(context).pop();
              } else {
                showGoMainMenuDialog(context);
              }
            },
          ),
        ),
        body: wordList.isEmpty
            ? Center(
                child: Text(
                  '아직 저장된 단어가 없습니다.',
                  style: TextStyle(fontSize: 17, color: Colors.brown),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(top: 13, bottom: 20),
                itemCount: wordList.length,
                itemBuilder: (context, idx) {
                  final w = wordList[idx];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 19, vertical: 4),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown!.withOpacity(0.2),
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(
                              w.word,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                              ),
                            ),
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                constraints: BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFF2F2F2F),
                                  size: 25,
                                ),
                                onPressed: () async {
                                  showDeleteWordDialog(context, () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final token =
                                        prefs.getString('access_token') ?? '';
                                    final int? wordId = wordList[idx].wordId;
                                    if (wordId == null) {
                                      setState(() {
                                        wordList.removeAt(idx);
                                      });
                                      return;
                                    }
                                    final success =
                                        await deleteWordFromWordbook(
                                          accessToken: token,
                                          wordId: wordId,
                                        );
                                    if (success) {
                                      setState(() {
                                        wordList.removeAt(idx);
                                      });
                                    } else {
                                      showAlertDialog(context, "단어 삭제 실패");
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                icon: Icon(
                                  w.isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Color(0xFF2F2F2F),
                                  size: 29,
                                ),
                                onPressed: () => toggleExpand(idx),
                              ),
                            ],
                          ),
                        ),
                        if (w.isExpanded)
                          Padding(
                            padding: EdgeInsets.fromLTRB(28, 0, 28, 15),
                            child: w.isLoading
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '의미 불러오는 중...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : w.isError
                                ? Text(
                                    '뜻을 불러오지 못했습니다.',
                                    style: TextStyle(color: Colors.red),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _detailRow(
                                              '유의어',
                                              (w.synonym == null ||
                                                      w.synonym!.trim().isEmpty)
                                                  ? '없음'
                                                  : w.synonym!,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 0,
                                                top: 4,
                                                right: 2,
                                              ),
                                              child: Text(
                                                '분야',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: _detailRow(
                                              '반의어',
                                              (w.antonym == null ||
                                                      w.antonym!.trim().isEmpty)
                                                  ? '없음'
                                                  : w.antonym!,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 8,
                                                top: 0,
                                              ),
                                              child: Text(
                                                w.field.isNotEmpty
                                                    ? w.field
                                                    : '없음',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      DottedLine(color: Colors.grey, height: 3),
                                      _detailRow('의미', w.meaning ?? "없음"),
                                      DottedLine(color: Colors.grey, height: 3),
                                      _detailRow(
                                        '예문',
                                        (w.example == null ||
                                                w.example!.trim().isEmpty)
                                            ? '없음'
                                            : w.example!,
                                      ),
                                    ],
                                  ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

Widget _detailRow(String title, String content) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$title: ', style: TextStyle(color: Colors.black87, fontSize: 13)),
      Expanded(
        // 반드시 Expanded로 감싸기!
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
          child: Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.black87),
            softWrap: true,
          ),
        ),
      ),
    ],
  );
}

void showDeleteWordDialog(BuildContext context, VoidCallback onConfirm) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 75, 15, 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "단어를 삭제하겠습니까?",
              style: TextStyle(
                color: Color(0xFF3A0B0B),
                fontWeight: FontWeight.w700,
                fontSize: 21,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 네 버튼
                SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF733E17),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                      ),
                      elevation: 2,
                    ),
                    child: Text('네'),
                  ),
                ),
                SizedBox(width: 5),
                // 아니요 버튼
                SizedBox(
                  width: 90,
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xFFFFF6DF),
                      foregroundColor: Color(0xFF733E17),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    child: Text('아니요'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

//단어장 api
Future<List<WordItemDto>> fetchWordbook({
  int page = 0,
  int size = 20,
  bool latestFirst = true,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token') ?? '';
  final baseurl = Uri.parse('http://43.202.149.234:8080/api/wordbook');
  final sortOrder = latestFirst ? "createdAt,desc" : "createdAt,asc";
  final url = baseurl.replace(
    queryParameters: {
      "page": "$page",
      "size": "$size",
      "sort": [sortOrder],
    },
  );

  print('[fetchWordbook] REQUEST URL: $url');
  print(
    '[fetchWordbook] REQUEST BODY: ${jsonEncode({
      "page": page,
      "size": size,
      "sort": [sortOrder],
    })}',
  );
  print(
    '[fetchWordbook] REQUEST HEADERS: ${{'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}}',
  );

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print('[fetchWordbook] RESPONSE statusCode: ${response.statusCode}');
  print('[fetchWordbook] RESPONSE body: ${response.body}');
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final List<dynamic> content = json['content'];
    return content.map((item) => WordItemDto.fromJson(item)).toList();
  } else {
    throw Exception('단어장 불러오기 실패');
  }
}

class WordItemDto {
  final int wordId;
  final String wordName;
  final String definition;
  final String example;
  final String wordCategory;
  final String? synonym;
  final String? antonym;
  final int shoulderNo;

  WordItemDto({
    required this.wordId,
    required this.wordName,
    required this.definition,
    required this.example,
    required this.wordCategory,
    this.synonym,
    this.antonym,
    required this.shoulderNo,
  });

  factory WordItemDto.fromJson(Map<String, dynamic> json) {
    return WordItemDto(
      wordId: json['wordId'],
      wordName: json['wordName'],
      definition: json['definition'],
      example: json['example'],
      wordCategory: json['wordCategory'],
      synonym: json['synonym'],
      antonym: json['antonym'],
      shoulderNo: json['shoulderNo'],
    );
  }
}

Future<bool> deleteWordFromWordbook({
  required String accessToken,
  required int wordId,
}) async {
  final url = Uri.parse('http://43.202.149.234:8080/api/wordbook');
  final response = await http.delete(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({"wordId": wordId}),
  );

  return response.statusCode == 200;
}

VocabWord fromWordItemDto(WordItemDto dto) {
  return VocabWord(
    wordId: dto.wordId,
    word: dto.wordName,
    meaning: dto.definition,
    example: dto.example,
    field: dto.wordCategory,
    synonym: dto.synonym,
    antonym: dto.antonym,
  );
}

class ScrapActivity {
  final String category;
  final int order;
  final DateTime activityDateTime;
  final String title;
  final String content;
  final String summary;
  final String opinion;
  final List<String> keywords;
  final List<String> unknownWords;
  final int articleId;

  ScrapActivity({
    required this.category,
    required this.order,
    required this.activityDateTime,
    required this.title,
    required this.content,
    required this.summary,
    required this.opinion,
    required this.keywords,
    required this.unknownWords,
    required this.articleId,
  });
}

List<ScrapActivity> get todaysActivities => allActivities
    .where(
      (a) =>
          a.activityDateTime.year == DateTime.now().year &&
          a.activityDateTime.month == DateTime.now().month &&
          a.activityDateTime.day == DateTime.now().day,
    )
    .toList();

class ScrapHistoryDetailPage extends StatelessWidget {
  final ScrapActivity activity;
  final List<FeedbackSectionData> feedbackSections;
  final List<String> unknownWords;
  final String userSummary;
  final String userOpinion;
  final String? modelSummary;
  final String? feedbackSummary;
  final String? modelOpinion;
  final String? feedbackOpinion;

  final List<String> keywords;

  const ScrapHistoryDetailPage({
    Key? key,
    required this.activity,
    required this.feedbackSections,
    required this.unknownWords,
    required this.userSummary,
    required this.userOpinion,
    required this.keywords,
    this.modelSummary,
    this.feedbackSummary,
    this.modelOpinion,
    this.feedbackOpinion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> feedbackWidgets = [];
    for (var i = 0; i < feedbackSections.length; i++) {
      final section = feedbackSections[i];
      String? extraBadge;
      switch (section.title) {
        case "기사 분야 파악하기":
        case "기사 제목 파악하기":
        case "주요 키워드 찾기":
          if (section.similarityScore != null) {
            extraBadge =
                '의미 유사도: ${(section.similarityScore! * 100).toStringAsFixed(0)}%';
          } else if (section.score != null) {
            extraBadge =
                '의미 유사도: ${(section.score! * 100).toStringAsFixed(0)}%';
          }
          break;
        case "요약하기":
          if (section.score != null)
            extraBadge = '요약 점수: ${(section.score! * 100).toStringAsFixed(0)}%';
          break;
        case "자신의 생각 키우기":
          if (section.evaluationScore != null &&
              section.evaluationScore!.contains(';')) {
            extraBadge =
                '사용자 유형: ${userTypeStringToCode(section.evaluationScore!)}';
          } else if (section.evaluationScore != null) {
            extraBadge = '사용자 유형: ${section.evaluationScore!}';
          }
          break;
      }
      feedbackWidgets.add(
        FeedbackSectionCard(
          title: section.title,
          myAnswer: section.myAnswer,
          modelAnswer: section.modelAnswer,
          feedback: section.feedback,
          extraBadge: extraBadge,
          similarityScore: section.similarityScore,
        ),
      );
      if (section.title == "주요 키워드 찾기") {
        feedbackWidgets.add(UnknownWordsCard(words: unknownWords));
      }
    }
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        automaticallyImplyLeading: false,
        leadingWidth: 105,
        leading: Padding(
          padding: const EdgeInsets.only(left: 11, top: 10, bottom: 8),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFFF6DF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.9),
              minimumSize: const Size(73, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "돌아가기",
              style: TextStyle(
                color: Color(0xFF3A0B0B),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontFamily: 'Pretendard',
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: primaryBrown,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 17, 15, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$modelSummary 뉴스 스크랩 ${activity.order}번째 활동',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        fontFamily: 'Jalnan2',
                      ),
                    ),
                    const SizedBox(height: 2),

                    Text(
                      DateFormat(
                        'yyyy년 MM월 dd일 HH:mm:ss',
                      ).format(activity.activityDateTime),
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            feedbackNewsSection(activity.content),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(17, 8, 17, 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDD94),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '스크랩 활동',
                      style: TextStyle(
                        color: Color(0xFF733E17),
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        fontFamily: 'Jalnan2',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  ...feedbackWidgets,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
