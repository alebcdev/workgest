import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
import 'package:workgest/providers/app_navigation_provider.dart';
import 'package:workgest/screens/user_list_screen.dart';
import 'package:workgest/screens/user_registration_screen.dart';
import 'package:workgest/screens/user_profile_screen.dart';
import 'package:workgest/screens/weather_screen.dart';
import 'model/user_item.dart';
import 'package:workgest/providers/weather_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
        create: (context) => AppNavigationProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppNavigationProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),
      ],
      child: Builder(
        builder: (context) {
          final navigatorKey =
              Provider.of<AppNavigationProvider>(context, listen: false)
                  .navigatorKey;
          final user = Provider.of<User?>(context);
          return MaterialApp(
              title: 'Autenticación de Workgest',
              theme: ThemeData(
                colorScheme:
                    ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
                useMaterial3: true,
              ),
              navigatorKey: navigatorKey,
              home: user == null ? const LoginScreen() : const HomeScreen(),
              onGenerateRoute: (settings) {
                if (user == null) {
                  // If user is not logged in, only allow navigation to login screen
                  return MaterialPageRoute(
                      builder: (context) => const LoginScreen());
                } else {
                  // If user is logged in, allow navigation to other screens
                  switch (settings.name) {
                    case '/home':
                      return MaterialPageRoute(
                          builder: (context) => const HomeScreen());
                    case '/registerUser':
                      return MaterialPageRoute(
                          builder: (context) => const UserRegistrationScreen());
                    case '/userList':
                      return MaterialPageRoute(
                          builder: (context) => const UserListScreen());
                    case '/userRegistration':
                      return MaterialPageRoute(
                          builder: (context) => const UserRegistrationScreen());
                    case '/summerCamperRegistration':
                      return MaterialPageRoute(
                          builder: (context) =>
                              const SummerCamperRegistrationScreen());
                    case '/weather':
                      return MaterialPageRoute(
                          builder: (context) => const WeatherScreen());
                    case '/userProfile':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                            builder: (context) => MyProfileScreen(user));
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/summerCamperManage':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                            builder: (context) => SummerCamperManage(user));
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/attendanceList':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                            builder: (context) => AttendanceListScreen(user));
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/material':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                            builder: (context) => MaterialScreen(user));
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/schedule':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                            builder: (context) => HorarioScreen(user));
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/userAdmin':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                            builder: (context) => UserAdminScreen(user: user));
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/userManage':
                      if (settings.arguments is User) {
                        final user = settings.arguments as User;
                        return MaterialPageRoute(
                          builder: (context) => UserManage(user),
                        );
                      } else {
                        return MaterialPageRoute(
                            builder: (context) =>
                                const HomeScreen()); // Handle null user
                      }

                    case '/updateUser':
                      final userItem = settings.arguments as UserItem;
                      return MaterialPageRoute(
                        builder: (context) =>
                            UpdateUserScreen(userItem: userItem),
                      );

                    default:
                      return null;
                  }
                }
              });
        },
      ),
    );
  }
}
