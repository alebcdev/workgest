import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../view/firebaseactions/alumnos/lista_asistencia_screen.dart';
import '../view/screens/horario_screen.dart';
import '../view/screens/material_screen.dart';
import '../view/screens/summercamper_manage_screen.dart';
import '../view/screens/user_manage_screen.dart';
import '../view/screens/user_profile_screen.dart';
import '../view/screens/weatherscreen.dart';

class AppNavigation{

  static void goToUserManage(BuildContext context, User user){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => UserManage(user))
    );
  }

  static void goToHorario(BuildContext context, User user){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => HorarioScreen(user))
    );
  }

  static void goToSummerCamperManage(BuildContext context, User user){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => SummerCamperManage(user))
    );
  }

  static void goToWeather(BuildContext context){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => WeatherApp())
    );
  }

  static void goToMaterial(BuildContext context, User user){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => MaterialScreen(user))
    );
  }

  static void goToProfile(BuildContext context, User user){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => MyProfileScreen(user))
    );
  }

  static void goToListaAsistencia(BuildContext context, User user){
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ListaAsistencia(user)));

  }

}