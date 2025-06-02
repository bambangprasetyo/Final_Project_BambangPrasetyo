import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:h8_fli_biometric_starter/model/geo.dart';
import 'package:h8_fli_biometric_starter/service/geo_service.dart';

import 'package:meta/meta.dart';

part 'geo_event.dart';
part 'geo_state.dart';

class GeoBloc extends Bloc<GeoEvent, GeoState> {
  final GeoService service;
  // TODO: 1. Initialize StreamSubscription<Geo> to manage the stream.
  StreamSubscription<Geo>? _subscription;
  bool _isRecording = false;

  GeoBloc({required this.service}) : super(GeoInitial()) {
    on<GeoInitEvent>((event, emit) async {
      try {
        emit(GeoLoading());
        final isGranted = await service.handlePermission();
        if (isGranted) {
          add(GeoGetLocationEvent());
          // TODO: 4. Call GeoStartRealtimeEvent to start listening.
          add(GeoStartRealtimeEvent());
        }
      } catch (e) {
        emit(GeoError(message: e.toString()));
      }
    });

    on<GeoGetLocationEvent>((event, emit) async {
      try {
        emit(GeoLoading());
        final geo = await service.getLocation();
        emit(GeoLoaded(geo: geo));
      } catch (e) {
        emit(GeoError(message: e.toString()));
      }
    });

    // TODO: 2. Add the GeoStartRealtimeEvent implementation.
    on<GeoStartRealtimeEvent>((event, emit) {
      _subscription = service.getLocationStream().listen((geo) {
        add(GeoUpdateLocationEvent(geo));
      });
    });

    // TODO: 3. Add the GeoUpdateLocationEvent implementation.
    on<GeoUpdateLocationEvent>((event, emit) {
      if (state is GeoLoaded) {
        final currState = state as GeoLoaded;

        emit(
          currState.copyWith(
            geo: event.geo,
            points:
                _isRecording
                    ? [...currState.points, event.geo]
                    : currState.points,
          ),
        );
      }
    });

    on<GeoStartRecordingEvent>((event, emit) {
      _isRecording = true;
    });

    on<GeoStopRecordingEvent>((event, emit) {
      _isRecording = false;
    });

    on<GeoResetHistoryEvent>((event, emit) {
      if (state is GeoLoaded) {
        final current = state as GeoLoaded;
        emit(current.copyWith(points: []));
      }
    });

    add(GeoInitEvent());
  }

  @override
  Future<void> close() {
    // TODO: 5. Cancel the StreamSubscription<Geo> to prevent memory leaks.
    _subscription?.cancel();
    return super.close();
  }
}
