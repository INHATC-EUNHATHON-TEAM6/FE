import 'package:flutter/material.dart';
import 'package:words_hanjoom/screens/learning_screen.dart';
import 'package:words_hanjoom/widgets/fields_select_container_widget.dart';
import 'package:words_hanjoom/widgets/header_widget.dart';
import 'package:words_hanjoom/widgets/learning_container_widget.dart';
import 'package:words_hanjoom/widgets/loading_widget.dart';
import 'package:words_hanjoom/widgets/navigation_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, Widget> map = {};
  String curLocation = "learning";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    map = {
      "learning": LearningContainerWidget(
        handleMainScreenWidget: handleMainScreenWidget,
      ),
      "fields_select": FieldsSelectContainerWidget(
        handleMainScreenWidget: handleMainScreenWidget,
        onFieldSelected: _handleFieldSelected,
      ),
    };
  }

  void handleMainScreenWidget(String locationName) {
    setState(() {
      curLocation = locationName;
    });
  }

  void _handleFieldSelected() {
    // 로딩 상태 활성화
    setState(() {
      isLoading = true;
    });

    // 2초 후 LearningScreen으로 이동
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LearningScreen()),
      );
    });
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: HeaderWidget(),
          body: map[curLocation],
          bottomNavigationBar: NavigationWidget(),
        ),
        if (isLoading) LoadingWidget(),
      ],
    );
  }
}
