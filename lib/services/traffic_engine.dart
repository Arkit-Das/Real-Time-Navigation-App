// lib/services/traffic_engine.dart
bool isTrafficHeavy() {
  final now = DateTime.now();
  // Heuristic: If it's between 1:30 PM and 2:30 PM, mark school zones red
  if (now.hour == 13 && now.minute >= 30) return true;
  return false;
}