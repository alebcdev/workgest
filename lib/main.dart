import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workgest/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:workgest/screens/attendance_list_screen.dart';
import 'package:workgest/screens/horario_screen.dart';
import 'package:workgest/screens/material_screen.dart';
import 'package:workgest/screens/summercamper_manage_screen.dart';
import 'package:workgest/screens/summercamper_registration_screen.dart';
import 'package:workgest/screens/update_user_screen.dart';
import 'package:workgest/screens/user_admin_screen.dart';
import 'package:workgest/screens/user_manage_screen.dart';
import 'firebase_options.dart';
import 'package:workgest/providers/app_navegation_provider.dart';
import 'package:workgest/screens/user_list_screen.dart';
import 'package:workgest/screens/user_registration_screen.dart';
import 'package:workgest/screens/user_profile_screen.dart';
import 'package:workgest/screens/weather_screen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppNavegationProvider()),
      ],
      child: MaterialApp(
        title: 'Autenticación de Workgest',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
          useMaterial3: true,
        ),
        navigatorKey: AppNavegationProvider().navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/userList': (context) => const UserListScreen(),
          '/userManage': (context) => const UserManageScreen(),
          '/userRegistration': (context) => const UserRegistrationScreen(),
          '/updateUser': (context) => const UpdateUserScreen(),
          '/userProfile': (context) => const UserProfileScreen(),
          '/summerCamperManage': (context) => const SummercamperManageScreen(),
          '/summerCamperRegistration': (context) => const SummercamperRegistrationScreen(),
          '/attendanceList': (context) => const AttendanceListScreen(),
          '/weather': (context) => const WeatherScreen(),
          '/material': (context) => const MaterialScreen(),
          '/schedule': (context) => const HorarioScreen(),

        },
        onGenerateRoute: (settings) {
          if (settings.name == '/userAdmin') {
            return MaterialPageRoute(builder: (context) => const UserAdminScreen());
          }
          // Handle other routes or return null for unhandled routes
          return null;
        },

      ),
    );
  }
}