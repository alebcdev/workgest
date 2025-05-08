import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppNavegationProvider with ChangeNotifier {
  String _currentRoute = '/login'; // Initial route

  String get currentRoute => _currentRoute;

  void changeRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }
}
