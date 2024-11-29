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
  String locationApiUrl =
      'http://localhost:3000/location/track'; // Backend location tracking API
  String quizApiUrl =
      'http://localhost:3000/quiz/generate'; // Backend quiz generation API URL
  Map<String, dynamic>? quizData;

  @override
  void initState() {
    super.initState();

    final locationService = LocationTrackingService(
      locationApiUrl: locationApiUrl,
      quizApiUrl: quizApiUrl,
      onQuizReady: (data) {
        setState(() {
          quizData = data;
        });
      },
    );

    locationService.checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Quiz App'),
      ),
      body: quizData == null
          ? Center(
              child: Text(
                'Tracking location... Stay in one place for a quiz!',
                textAlign: TextAlign.center,
              ),
            )
          : QuizDisplay(quizData: quizData!),
    );
  }
}
