import 'package:flutter/material.dart';
import 'package:words_hanjoom/widgets/fields_select_container_widget.dart';
import 'package:words_hanjoom/widgets/header_widget.dart';
import 'package:words_hanjoom/widgets/learning_container_widget.dart';
import 'package:words_hanjoom/widgets/navigation_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, Widget> map = {};
  String curLocation = "learning";

  @override
  void initState() {
    super.initState();
    map = {
      "learning": LearningContainerWidget(
        handleMainScreenWidget: handleMainScreenWidget,
      ),
      "fields_select": FieldsSelectContainerWidget(
        handleMainScreenWidget: handleMainScreenWidget,
      ),
    };
  }

  void handleMainScreenWidget(String locationName) {
    setState(() {
      curLocation = locationName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderWidget(),
      body: map[curLocation],
      bottomNavigationBar: NavigationWidget(),
    );
  }
}
