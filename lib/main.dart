import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/courses_screen.dart';
import 'package:myapp/screens/quizzes_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/chat_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/auth/signup_screen.dart';
import 'package:myapp/screens/modules_screen.dart';
import 'package:myapp/screens/lesson_screen.dart';
import 'package:myapp/screens/profile/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MyApp(),
  ));
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';

      if (!loggedIn && !isLoggingIn && !isSigningUp) {
        return '/login';
      }
      if (loggedIn && (isLoggingIn || isSigningUp)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login',builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(path: '/signup',builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(path: '/courses',builder: (context, state) => const CoursesScreen(),
      ),
      GoRoute(
        path: '/quizzes',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return QuizzesScreen(
            lessonId: extra?['lessonId'] ?? '',
            lessonContent: extra?['lessonContent'] ?? '',
          );
        },
      ),
       GoRoute(path: '/chat',builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(path: '/profile',builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(path: '/courses/:courseId/modules',builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return ModulesScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/courses/:courseId/modules/:moduleId/lessons/:lessonId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          final moduleId = state.pathParameters['moduleId']!;
          final lessonId = state.pathParameters['lessonId']!;
          return LessonScreen(courseId: courseId, moduleId: moduleId, lessonId: lessonId);
        },
      ),
      GoRoute(path: '/edit-profile',builder: (context, state) => const EditProfileScreen(),
      ),
    ],
    initialLocation: '/login', 
    errorBuilder: (context, state) => const Scaffold(body: Center(child: Text('Page not found'))), // Added an error page
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  ),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  ),
);
