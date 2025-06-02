// lib/screens/home_staff.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../service/nfc_service.dart';
import '../service/location_service.dart';
import '../service/firebase_tracking_service.dart';

class HomeStaff extends StatefulWidget {
  const HomeStaff({super.key});

  @override
  State<HomeStaff> createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
  final NFCService _nfcService = NFCService();
  final LocationService _locationService = LocationService();
  final FirebaseTrackingService _trackingService = FirebaseTrackingService();

  String _assignment = '';
  final List<LatLng> _track = [];
  bool _tracking = false;

  void _readNFCAndStartTracking() async {
    final tagData = await _nfcService.readNfcTag();
    if (tagData == null) return;

    // Optional: double check to Firebase assignment list (not implemented here)
    setState(() => _assignment = tagData);

    _locationService.trackLocation((position) {
      final latlng = LatLng(position.latitude, position.longitude);
      setState(() => _track.add(latlng));
      _trackingService.savePoint(_assignment, latlng);
    });

    setState(() => _tracking = true);
  }

  @override
  void dispose() {
    _locationService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Home')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _readNFCAndStartTracking,
            child: const Text('Read NFC & Start Tracking'),
          ),
          if (_assignment.isNotEmpty) Text('Assignment: $_assignment'),
          if (_tracking)
            Expanded(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-6.2, 106.8),
                  zoom: 14,
                ),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: Colors.blue,
                    width: 5,
                    points: _track,
                  ),
                },
                markers:
                    _track.isNotEmpty
                        ? {
                          Marker(
                            markerId: const MarkerId('current'),
                            position: _track.last,
                          ),
                        }
                        : {},
              ),
            ),
        ],
      ),
    );
  }
}
