import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/quiz_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/host/host_dashboard_screen.dart';
import 'screens/host/create_quiz_screen.dart';
import 'screens/host/quiz_details_screen.dart';
import 'screens/participant/participant_home_screen.dart';
import 'screens/participant/quiz_screen.dart';
import 'screens/participant/result_screen.dart';
import 'screens/participant/leaderboard_screen.dart';
import 'screens/shared/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar', null);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const QuizBattleApp());
}

class QuizBattleApp extends StatelessWidget {
  const QuizBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp(
          title: 'QuizBattle',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/host-dashboard': (_) => const HostDashboardScreen(),
            '/create-quiz': (_) => const CreateQuizScreen(),
            '/quiz-details': (_) => const QuizDetailsScreen(),
            '/participant-home': (_) => const ParticipantHomeScreen(),
            '/quiz': (_) => const QuizScreen(),
            '/result': (_) => const ResultScreen(),
            '/leaderboard': (_) => const LeaderboardScreen(),
            '/profile': (_) => const ProfileScreen(),
          },
        ),
      ),
    );
  }
}
