import 'package:flutter/material.dart';
import '../../providers/app_navegation_provider.dart';

class HomeWidget extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;

  const HomeWidget({
    Key? key,
    required this.title,
    required this.route,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenHeight * 0.03,
          ),
        ),
        SizedBox(height: 10),
        InkWell(
          onTap: () {
            AppNavegationProvider().changeRoute(route);
          },
          child: Icon(
            icon,
            size: screenHeight * 0.1,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
