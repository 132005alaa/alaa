import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthy_food/features/Home/HomePage.dart';
import 'package:healthy_food/features/navBar/Notifications/NotificationsPage.dart';
import 'package:healthy_food/features/on_boarding/Onboarding3Page.dart';
import 'package:healthy_food/features/splash/SplashPage.dart';
import 'package:healthy_food/features/authentication/screens/LoginScreen.dart';
import 'package:healthy_food/features/authentication/screens/RegisterScreen.dart';
import 'package:healthy_food/features/authentication/screens/SuccessScreen.dart';
import 'package:healthy_food/features/authentication/screens/ForgotPasswordScreen.dart';
import 'package:healthy_food/features/authentication/screens/VerifyScreen.dart';
import 'package:healthy_food/features/Information/InfoPage.dart';
import 'package:healthy_food/features/Information/GoalPage.dart';
import 'package:healthy_food/features/Information/CongratulationsPage.dart';
import 'package:healthy_food/features/navBar/Informations/InfoTipsPage.dart';
import 'package:healthy_food/features/navBar/water/WaterPage.dart';
import 'package:healthy_food/features/navBar/Analysis/AnalysisPage.dart';
import 'package:healthy_food/features/Home/MealSelectionPage.dart';
import 'package:healthy_food/features/Home/LunchSelectionPage.dart';
import 'package:healthy_food/features/Home/DinnerSelectionPage.dart';
import 'package:healthy_food/features/Home/SnacksSelectionPage.dart';
import 'package:healthy_food/features/Home/WorkoutSelectionPage.dart';
import 'dart:async';
import 'package:healthy_food/services/notification_service.dart';

void _startNotificationScheduler() {
  Timer.periodic(Duration(hours: 3), (timer) async {
    await NotificationService().addWaterReminderNotification();
    print(' تم إضافة إشعار شرب الماء');
  });

  Timer.periodic(Duration(hours: 6), (timer) async {
    await NotificationService().addMotivationalNotification();
    print(' تم إضافة إشعار تحفيزي');
  });

  Timer.periodic(Duration(hours: 24), (timer) async {
    final now = DateTime.now();
    if (now.hour == 17 && now.minute == 0) {
      await NotificationService().addWorkoutReminder();
      print(' تم إضافة إشعار تمرين');
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print(' Firebase initialized successfully');

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print(' User is currently signed out');
    } else {
      print(' User is signed in: ${user.email}');
    }
  });

  _startNotificationScheduler();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/onboarding3': (context) => Onboarding3Page(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/success': (context) => const SuccessScreen(),
        '/forgot': (context) => ForgotPasswordScreen(),
        '/verify': (context) => VerifyScreen(),
        '/info': (context) => const InfoPage(),
        '/goal': (context) => const GoalPage(),
        '/congrats': (context) => const CongratulationsPage(),
        '/home': (context) => const HomePage(),
        '/notifications': (context) => const NotificationsPage(),
        '/infotips': (context) => const InfoTipsPage(),
        '/water': (context) => const WaterPage(),
        '/Analysis': (context) => const AnalysisPage(),
        '/MealSelection': (context) => const MealSelectionPage(),
        '/LunchSelection': (context) => const LunchSelectionPage(),
        '/DinnerSelection': (context) => const DinnerSelectionPage(),
        '/SnacksSelection': (context) => const SnacksSelectionPage(),
        '/WorkoutSelection': (context) => const WorkoutSelectionPage(),
      },
    );
  }
}
