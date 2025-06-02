import 'package:flutter/material.dart';
import 'package:h8_fli_biometric_starter/model/geo.dart';

class HistoryView extends StatelessWidget {
  final List<Geo> points;

  const HistoryView({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: points.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final geo = points[index];
          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text('Lat: ${geo.latitude}, Lng: ${geo.longitude}, Waktu: ${geo.timestamp}'),
            subtitle: Text('Point #${index + 1}'),
          );
        },
      ),
    );
  }
}
