import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseTrackingService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> savePoint(String assignmentId, LatLng point) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _db.child('tracking/$assignmentId').push().set({
      'lat': point.latitude,
      'lng': point.longitude,
      'timestamp': timestamp,
    });
  }

  Future<List<LatLng>> getTrack(String assignmentId) async {
    final snapshot = await _db.child('tracking/$assignmentId').get();
    final List<LatLng> track = [];
    for (final child in snapshot.children) {
      final data = child.value as Map;
      final lat = data['lat'] as double;
      final lng = data['lng'] as double;
      track.add(LatLng(lat, lng));
    }
    return track;
  }
}
