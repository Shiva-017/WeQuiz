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
  StreamSubscription<Position>? _positionStreamSubscription;

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
    _positionStreamSubscription = Geolocator.getPositionStream(
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
          await _trackLocation(_lastPosition!);
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

  Future<String?> _getLocationKeyword(Position position) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          // Extract a meaningful location (e.g., city or region)
          final location = data["display_name"];
          return location; // Return the resolved address
        }
      } else {
        print('Error during reverse geocoding: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while reverse geocoding: $error');
    }

    return null; // Return null if reverse geocoding fails
  }

  Future<void> _generateQuiz(Position position) async {
    try {
      final locationKeyword = await _getLocationKeyword(position);

      if (locationKeyword == null) {
        print('Failed to resolve location keyword. Skipping quiz generation.');
        return;
      }
      final response = await http.post(
        Uri.parse(quizApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'locationKeyword': locationKeyword,
        }),
      );

      if (response.statusCode == 200) {
        final quizData = jsonDecode(response.body) as Map<String, dynamic>;
        print(quizData);
        onQuizReady(quizData); // Provide the quiz data to the UI
      } else {
        print('Error generating quiz: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while generating quiz: $error');
    }
  }

  /// Function to stop location tracking and quiz generation
  void stopService() {
    // Cancel the position stream subscription
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    // Cancel the periodic timer
    _timer?.cancel();
    _timer = null;

    print('Location tracking and quiz generation stopped.');
  }
}
