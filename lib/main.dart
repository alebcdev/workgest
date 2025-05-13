import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workgest/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:workgest/screens/attendance_list_screen.dart';
import 'package:workgest/screens/home_screen.dart';
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
import 'package:firebase_app_check/firebase_app_check.dart';
import 'model/user_item.dart';
import 'package:flutter/foundation.dart';
import 'package:workgest/providers/weather_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize App Check with a debug provider for development
  await dotenv.load(fileName: ".env");
  await FirebaseAppCheck.instance.activate(
    // You can use DebugProvider during development
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
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
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: Builder(
        builder: (context) {
          final navigatorKey = Provider.of<AppNavegationProvider>(context, listen: false).navigatorKey;
          return MaterialApp(
            title: 'Autenticación de Workgest',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
              useMaterial3: true,
            ),
            navigatorKey: navigatorKey,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(), // Register the new home route
              '/registerUser': (context) => const UserRegistrationScreen(),
              '/userList': (context) => const UserListScreen(),
              '/userRegistration': (context) => const UserRegistrationScreen(),
              '/summerCamperRegistration': (context) => const SummerCamperRegistrationScreen(),
              '/weather': (context) => const WeatherScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/userProfile':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => MyProfileScreen(user),
                  );

                case '/summerCamperManage':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => SummerCamperManage(user),
                  );

                case '/attendanceList':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => AttendanceListScreen(user),
                  );

                case '/material':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => MaterialScreen(user),
                  );

                case '/schedule':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => HorarioScreen(user),
                  );

                case '/userAdmin':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => UserAdminScreen(user: user),
                  );

                case '/userManage':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (context) => UserManage(user),
                  );

                case '/updateUser':
                  final userItem = settings.arguments as UserItem;
                  return MaterialPageRoute(
                    builder: (context) => UpdateUserScreen(userItem: userItem),
                  );

                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
