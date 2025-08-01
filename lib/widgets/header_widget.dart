import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 44),
        Container(
          decoration: BoxDecoration(
            color: Color(0xff733E17),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 6, bottom: 8),
                child: Image.asset('assets/logos/app_logo.png', width: 110),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xffececec), width: 1),
                ),
                margin: EdgeInsets.symmetric(vertical: 18, horizontal: 13),
                child: Container(
                  padding: EdgeInsets.all(11),
                  child: Image.asset("assets/icons/profile.png", width: 18.67),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
