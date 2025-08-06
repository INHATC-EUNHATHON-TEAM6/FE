import 'package:flutter/material.dart';

class NavigationWidget extends StatelessWidget {
  const NavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff733E17),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Padding(
          padding: EdgeInsets.only(top: 9, bottom: 16),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.white,
            selectedLabelStyle: TextStyle(fontSize: 14, fontFamily: "Jalnan"),
            unselectedLabelStyle: TextStyle(fontSize: 14, fontFamily: "Jalnan"),
            items: [
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/study.png", width: 36),
                label: "학습",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/record.png", width: 36),
                label: "기록",
              ),
              BottomNavigationBarItem(
                icon: Image.asset("assets/icons/dashboard.png", width: 36),
                label: "대시보드",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
