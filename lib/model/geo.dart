class Geo {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  Geo({
    required this.latitude,
    required this.longitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
