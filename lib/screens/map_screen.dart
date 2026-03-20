import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:navigate/services/ai_routing.dart';
import 'package:navigate/widgets/search_overlay.dart';
import 'package:navigate/model/hotspot.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? mapController;
  final AIRoutingService _aiService = AIRoutingService();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
  }

  void _onPlaceSelected(double lat, double lon) async {
    List<LatLng> routePoints = await _aiService.getRouteFromCoords(lat, lon);

    if (routePoints.isNotEmpty && mapController != null) {
      await mapController!.clearLines();
      await mapController!.addLine(
        LineOptions(
          geometry: routePoints,
          lineColor: "#FF0000",
          lineWidth: 5.0,
          lineOpacity: 0.8,
        ),
      );

      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lon), 14.0),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Route not found. Check your GPS/Internet.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. PULL THE KEY HERE (Inside the build method, but outside the return)
    final String maptilerKey = dotenv.env['MAPTILER_KEY'] ?? "";

    double currentZoom = mapController?.cameraPosition?.zoom ?? 12.0;
    final traffic = GlobalTrafficEngine.getTrafficStatus(
      zoom: currentZoom,
      speedInMps: 0.0,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 2. THE DYNAMIC MAP
          MapLibreMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationRenderMode: MyLocationRenderMode.compass,
            myLocationTrackingMode: MyLocationTrackingMode.tracking,
            initialCameraPosition: const CameraPosition(
                target: LatLng(19.0760, 72.8777),
                zoom: 12.0
            ),
            // CLEAN URL:
            styleString: "https://api.maptiler.com/maps/streets-v2/style.json?key=$maptilerKey",
          ),

          Positioned(
            top: 50, left: 20, right: 20,
            child: SearchOverlay(onLocationSelected: _onPlaceSelected),
          ),

          Positioned(
            bottom: 30, left: 20,
            child: Chip(
              backgroundColor: Colors.white,
              side: BorderSide(color: traffic['color']),
              label: Text(traffic['label'], style: TextStyle(color: traffic['color'])),
            ),
          ),

          Positioned(
            bottom: 30, right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                Position pos = await Geolocator.getCurrentPosition();
                mapController?.animateCamera(
                    CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude))
                );
              },
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}