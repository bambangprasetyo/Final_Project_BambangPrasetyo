import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:h8_fli_biometric_starter/manager/geo_bloc.dart';
import 'package:h8_fli_biometric_starter/model/geo.dart';
import 'package:h8_fli_biometric_starter/view/history_view.dart';

class GeoView extends StatefulWidget {
  const GeoView({super.key});

  @override
  State<GeoView> createState() => _GeoViewState();
}

class _GeoViewState extends State<GeoView> {
  late final CameraPosition _cameraPosition;
  GoogleMapController? _mapController;
  LatLng? _startPoint;
  LatLng? _endPoint;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _cameraPosition = const CameraPosition(target: LatLng(0.0, 0.0), zoom: 5);
  }

  void _updateCameraPosition(Geo geo) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(geo.latitude, geo.longitude), zoom: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeoBloc, GeoState>(
      listener: (context, state) {
        if (state is GeoLoaded) {
          _updateCameraPosition(state.geo);
          if (state.isRecording &&
              _startPoint == null &&
              state.points.isNotEmpty) {
            // Simpan titik awal saat mulai merekam
            _startPoint = LatLng(
              state.points.first.latitude,
              state.points.first.longitude,
            );
          }

          if (!state.isRecording && state.points.isNotEmpty) {
            // Simpan titik akhir saat berhenti merekam
            _endPoint = LatLng(
              state.points.last.latitude,
              state.points.last.longitude,
            );
          }
        }

        if (state is GeoLoaded) {
          _updateCameraPosition(state.geo);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: switch (state) {
                GeoInitial() => const SizedBox(),
                GeoLoading() => const CircularProgressIndicator(),
                GeoLoaded() => GoogleMap(
                  myLocationButtonEnabled: false,
                  initialCameraPosition: _cameraPosition,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('current-location'),
                      position: LatLng(state.geo.latitude, state.geo.longitude),
                    ),
                    if (_startPoint != null)
                      Marker(
                        markerId: const MarkerId('start-point'),
                        position: _startPoint!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        infoWindow: const InfoWindow(title: 'Start'),
                      ),
                    if (_endPoint != null)
                      Marker(
                        markerId: const MarkerId('end-point'),
                        position: _endPoint!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow: const InfoWindow(title: 'End'),
                      ),
                  },

                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route-poliline'),
                      color: Colors.pink,
                      width: 4,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                      points:
                          state.points
                              .map(
                                (point) =>
                                    LatLng(point.latitude, point.longitude),
                              )
                              .toList(),
                    ),
                  },
                ),
                GeoError() => Text(state.message ?? ''),
              },
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: MouseRegion(
            onHover: (event) {
              final screenHeight = MediaQuery.of(context).size.height;
              final y = event.position.dy;

              // Jika cursor dekat dengan bawah layar (misalnya 100px dari bawah)
              if (y > screenHeight - 100) {
                if (_isFabVisible) {
                  setState(() {
                    _isFabVisible = false;
                  });
                }
              } else {
                if (!_isFabVisible) {
                  setState(() {
                    _isFabVisible = true;
                  });
                }
              }
            },
            child: AnimatedOpacity(
              opacity: _isFabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.9 * 255).toInt()),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: 'Rekam',
                      onPressed: () {
                        setState(() {
                          _startPoint = null;
                          _endPoint = null;
                        });
                        context.read<GeoBloc>().add(GeoStartRecordingEvent());
                      },
                      mini: true,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.fiber_manual_record),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'Stop',
                      onPressed: () {
                        context.read<GeoBloc>().add(GeoStopRecordingEvent());
                      },
                      mini: true,
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.stop),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'History',
                      onPressed: () {
                        final state = context.read<GeoBloc>().state;
                        if (state is GeoLoaded) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HistoryView(points: state.points),
                            ),
                          );
                        }
                      },
                      mini: true,
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.history),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'Reset',
                      onPressed: () {
                        context.read<GeoBloc>().add(GeoResetHistoryEvent());
                        setState(() {
                          _startPoint = null;
                          _endPoint = null;
                        });
                      },
                      mini: true,
                      backgroundColor: Colors.blueGrey,
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
