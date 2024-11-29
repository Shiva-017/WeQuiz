import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class LocationTrackingService {
  Position? _lastPosition;
  DateTime? _lastTimestamp;
  final String locationApiUrl;
  final String quizApiUrl;
  final Function(Map<String, dynamic>) onQuizReady;
  Timer? _timer; // Timer to trigger periodic checks

  LocationTrackingService({
    required this.onQuizReady,
    required this.locationApiUrl,
    required this.quizApiUrl,
  });

  Future<void> checkPermissions() async {
    // Check if permission is granted
    PermissionStatus status = await Permission.location.request();
    PermissionStatus statusAlways = await Permission.locationAlways.request();

    if (status.isGranted && statusAlways.isGranted) {
      // Permission is granted, proceed with location tracking
      startTracking();
    } else {
      // If permission is not granted, request it
      print('Location permission denied');
    }
  }

  Future<void> startTracking() async {
    // Start listening for location updates
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position currentPosition) {
      _lastPosition = currentPosition;
      _lastTimestamp = DateTime.now();
    });

    // Start the timer to check periodically (every 1 minute)
    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      if (_lastPosition != null && _lastTimestamp != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          _lastPosition!.latitude,
          _lastPosition!.longitude,
        );

        // Only call the backend if the user is within the same area (10 km)
        if (distance < 10000) {
          final duration = DateTime.now().difference(_lastTimestamp!);

          if (duration.inMinutes >= 1) {
            // Call the API if the user stayed in the same location for 1 minute
            await _trackLocation(_lastPosition!);
          }
        }
      }
    });
  }

  Future<void> _trackLocation(Position position) async {
    try {
      final response = await http.post(
        Uri.parse(locationApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        print('Location tracked successfully');
        await _generateQuiz(
            position); // Call to generate the quiz after tracking location
      } else {
        print('Error tracking location: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while tracking location: $error');
    }
  }

  Future<void> _generateQuiz(Position position) async {
    try {
      final response = await http.post(
        Uri.parse(quizApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final quizData = jsonDecode(response.body) as Map<String, dynamic>;
        onQuizReady(quizData); // Provide the quiz data to the UI
      } else {
        print('Error generating quiz: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while generating quiz: $error');
    }
  }

  // To cancel the periodic timer when not needed anymore
  void stopTracking() {
    _timer?.cancel();
  }
}
