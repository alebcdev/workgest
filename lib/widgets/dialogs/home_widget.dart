import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../providers/app_navegation_provider.dart';

class Home extends StatefulWidget {
  final User user;

  const Home({super.key, required this.user});
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home>{
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context){
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = screenHeight * 0.1;
    double fonSizeMedium = screenHeight * 0.03;

    List<Widget> botones = [
      Column(
        children: [
          Text(
            'Usuarios',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonSizeMedium
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                AppNavigation.goToUserManage(context, _user);
              },
              icon: Icon(Icons.app_registration, size: iconSize, color: Colors.white),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Horario',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonSizeMedium
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                AppNavigation.goToHorario(context, _user);
              },
              icon: Icon(Icons.calendar_month_outlined, size: iconSize, color: Colors.white),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Alumnos',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonSizeMedium
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                AppNavigation.goToSummerCamperManage(context, _user);
              },
              icon: Icon(Icons.list_rounded, size: iconSize, color: Colors.white),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Tiempo',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonSizeMedium
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                AppNavigation.goToWeather(context);
              },
              icon: Icon(Icons.sunny, size: iconSize, color: Colors.white),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Actividades',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonSizeMedium
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                AppNavigation.goToMaterial(context, _user);
              },
              icon: Icon(Icons.kayaking_rounded, size: iconSize, color: Colors.white),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            'Mi cuenta',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonSizeMedium
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                AppNavigation.goToProfile(context, _user);
              },
              icon: Icon(Icons.account_circle, size: iconSize, color: Colors.white),
            ),
          ),
        ],
      ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: MediaQuery.of(context).size.height / (MediaQuery.of(context).size.width * 2.4),
      ),
      itemCount: botones.length,
      itemBuilder: (context, index){
        return Card(
          color: _colorItem(index),
          elevation: 5,
          child: botones[index],
        );
      },
    );
  }

  Color _colorItem(int index){
    switch(index){
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.blueAccent[100]!;
      case 5:
        return Colors.purple[200]!;
      default:
        return Colors.white;
    }
  }
}