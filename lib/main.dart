import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_quiz/screens/auth_screen.dart';
import 'package:we_quiz/screens/create_quiz.dart';
import 'package:we_quiz/screens/game_selection_screen.dart';
import 'package:we_quiz/screens/leaderboard_screen.dart';
import 'package:we_quiz/screens/start_quiz.dart';
import 'package:we_quiz/screens/ui_toggle.dart';
import 'package:we_quiz/screens/quiz_ready.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SourGummy',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/quiz-type': (context) => QuizModeSelector(),
        '/game-selection': (context) => GameSelectionScreen(),
        '/create-quiz': (context) => CreateQuizScreen(
            roomId: ModalRoute.of(context)!.settings.arguments as String),
        '/start-quiz': (context) => StartQuizScreen(
            roomId: ModalRoute.of(context)!.settings.arguments as String),
        '/leaderboard': (context) => LeaderboardScreen(
            roomId: ModalRoute.of(context)!.settings.arguments as String),
        '/location-quiz': (context) => QuizScreen(),
      },
    );
  }
}
