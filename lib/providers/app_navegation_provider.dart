import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workgest/screens/attendance_list_screen.dart';

import '../screens/horario_screen.dart';
import '../screens/material_screen.dart';
import '../screens/summercamper_manage_screen.dart';
import '../screens/user_manage_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/weather_screen.dart';

class AppNavigation {
  static void goToUserManage(BuildContext context, User user) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => UserManage(user)));
  }

  static void goToHorario(BuildContext context, User user) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HorarioScreen(user)));
  }

  static void goToSummerCamperManage(BuildContext context, User user) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => SummerCamperManage(user)));
  }

  static void goToWeather(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => WeatherApp()));
  }

  static void goToMaterial(BuildContext context, User user) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MaterialScreen(user)));
  }

  static void goToProfile(BuildContext context, User user) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MyProfileScreen(user)));
  }

  static void goToListaAsistencia(BuildContext context, User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttendanceListScreen(
            user), // o ListaAsistencia(user.uid) si espera String
      ),
    );
  }
}
