import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNavigationProvider with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  User? _user;
  String _currentRoute = '/login';

  String get currentRoute => _currentRoute;
  User? get user => _user;

  AppNavigationProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  void changeRoute(String route) {
    _currentRoute = route;
    navigatorKey.currentState?.pushNamed(route);
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Error message
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}


