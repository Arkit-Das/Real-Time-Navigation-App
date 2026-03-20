import 'package:dio/dio.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';

class AIRoutingService {
  final Dio _dio = Dio(
    BaseOptions(
      // 1. Set a reasonable timeout so it doesn't hang forever
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),

      // 2. THIS IS THE FIX: The "User-Agent" header
      headers: {
        'User-Agent': 'NaviNavProject_StudentEdition_v1', // Give it a unique name
        'Accept': 'application/json',
      },
    ),
  );

  // 1. GET SUGGESTIONS AS YOU TYPE
  Future<List<Map<String, dynamic>>> getSearchSuggestions(String query) async {
    try {
      final url = "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5";
      final response = await _dio.get(url);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print("Search Error: $e");
      return [];
    }
  }

  // 2. GET THE SHORTEST ROUTE
  Future<List<LatLng>> getRouteFromCoords(double destLat, double destLon) async {
    try {
      Position userPos = await Geolocator.getCurrentPosition();
      final routeUrl = "https://router.project-osrm.org/route/v1/driving/"
          "${userPos.longitude},${userPos.latitude};$destLon,$destLat"
          "?overview=full&geometries=polyline";

      final response = await _dio.get(routeUrl);
      if (response.data['routes'] != null && (response.data['routes'] as List).isNotEmpty) {
        return _decodePolyline(response.data['routes'][0]['geometry']);
      }
    } catch (e) {
      print("Routing Error: $e");
    }
    return [];
  }

  // Helper to decode the polyline into map points
  List<LatLng> _decodePolyline(String str) {
    List<LatLng> points = [];
    int index = 0, len = str.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      shift = 0; result = 0;
      do {
        b = str.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}