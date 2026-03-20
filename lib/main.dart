import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/map_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Ensure this is in pubspec.yaml

void main() async {
  // 1. MUST ADD: Initialize Flutter bindings for async tasks
  WidgetsFlutterBinding.ensureInitialized();

  // 2. MUST ADD: Load the environment variables before the app starts
  try {
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded!");
  } catch (e) {
    print("Error loading .env: $e");
  }

  runApp(const HyperLocalNavigator());
}

class HyperLocalNavigator extends StatelessWidget {
  const HyperLocalNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyper-Local AI Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
      ),
      home: const PermissionWrapper(),
    );
  }
}

class PermissionWrapper extends StatefulWidget {
  const PermissionWrapper({super.key});

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
  }

  Future<void> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    if (mounted) {
      setState(() {
        _isPermissionGranted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isPermissionGranted
        ? MapScreen()
        : const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Initializing Map & GPS..."),
          ],
        ),
      ),
    );
  }
}