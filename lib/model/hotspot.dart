import 'package:flutter/material.dart';

class GlobalTrafficEngine {
  /// Predicts traffic based on global time-of-day and environmental context (Zoom).
  /// Zoom >= 14 typically means the user is looking at local/urban streets.
  /// Zoom < 12 typically means the user is on a highway or inter-city road.
  static Map<String, dynamic> getTrafficStatus({
    required double zoom,
    required double speedInMps, // Speed in Meters per Second from GPS
  }) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // Convert speed to km/h for easier logic
    final speedKmH = speedInMps * 3.6;
    bool isUrban = zoom >= 14.0;

    // 1. GLOBAL PEAK HOURS (Rush Hour)
    // 08:00 - 10:00 or 17:30 - 19:30
    bool isPeak = (hour >= 8 && hour <= 10) ||
        (hour == 17 && minute >= 30) ||
        (hour == 18) ||
        (hour == 19 && minute <= 30);

    // 2. LOGIC: Speed-Based Override (Real-time detection)
    // If you're moving < 10km/h in an Urban zone, that's heavy traffic regardless of time.
    if (isUrban && speedKmH > 0.5 && speedKmH < 12.0) {
      return {"label": "Traffic Detected", "color": Colors.red};
    }

    // 3. LOGIC: Time + Environment Prediction
    if (isPeak) {
      return isUrban
          ? {"label": "Urban Rush: Heavy", "color": Colors.red}
          : {"label": "Highway: Moderate", "color": Colors.orange};
    }

    // Mid-day "School/Lunch" bumps
    if (hour >= 13 && hour <= 14) {
      return {"label": "Local: Moderate", "color": Colors.orange};
    }

    // Default: Smooth sailing
    return {"label": "Open Road: Clear", "color": Colors.green};
  }
}