import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_quiz/screens/quiz_screen.dart';
import '../services/location_tracking_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final String locationApiUrl =
      'https://location-based-quiz-workers.dasi-s.workers.dev/track-user-location'; // Backend location tracking API
  final String quizApiUrl =
      'https://location-based-quiz-workers.dasi-s.workers.dev/generate-quiz'; // Backend quiz generation API URL
  Map<String, dynamic>? quizData;
  late LocationTrackingService locationService;
  bool isQuizGenerated = false; // Flag to prevent repeated API calls

  @override
  void initState() {
    super.initState();

    // Initialize location tracking service only once
    locationService = LocationTrackingService(
      locationApiUrl: locationApiUrl,
      quizApiUrl: quizApiUrl,
      onQuizReady: (data) {
        if (!isQuizGenerated) {
          setState(() {
            quizData = data;
            isQuizGenerated = true;
          });

          // Stop the location service before navigating
          locationService.stopService();

          // Navigate to the QuizDisplay widget
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDisplay(quizData: quizData!),
            ),
          );
        }
      },
    );

    // Start tracking location only if quizData is not already available
    if (!isQuizGenerated) {
      locationService.checkPermissions();
    }
  }

  @override
  void dispose() {
    // Clean up the tracking service when leaving this screen
    locationService.stopService(); // Stop the location tracking service
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Quiz App'),
      ),
      body: Center(
        child: quizData == null
            ? Text(
                'Tracking location... Stay in one place for a quiz!',
                textAlign: TextAlign.center,
              )
            : CircularProgressIndicator(), // Optional progress indicator until navigation
      ),
    );
  }
}
