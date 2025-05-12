import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppNavegationProvider with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentRoute = '/login';

  String get currentRoute => _currentRoute;

  void changeRoute(String route) {
    _currentRoute = route;
    navigatorKey.currentState?.pushNamed(route);
    notifyListeners();
  }
}

