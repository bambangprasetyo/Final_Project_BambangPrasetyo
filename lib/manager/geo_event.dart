part of 'geo_bloc.dart';

@immutable
sealed class GeoEvent {}

class GeoInitEvent extends GeoEvent {}

class GeoGetLocationEvent extends GeoEvent {}

// TODOL 1. Add GeoStartRealtimeEvent to start listening for realtime location.
class GeoStartRealtimeEvent extends GeoEvent {}

// TODO: 2. Add GeoUpdateLocationEvent to update the location state.
class GeoUpdateLocationEvent extends GeoEvent{
  GeoUpdateLocationEvent(this.geo);
  final Geo geo;
}

class GeoStartRecordingEvent extends GeoEvent {}

class GeoStopRecordingEvent extends GeoEvent {}

class GeoResetHistoryEvent extends GeoEvent {}
