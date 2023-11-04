part of 'google_map_bloc.dart';

abstract class GoogleMapEvent extends Equatable {
  GoogleMapEvent();

  @override
  List<Object?> props = [];
}

class OnLoadPredictionsEvent extends GoogleMapEvent {
  final String text;

  OnLoadPredictionsEvent(this.text);
}

class OnClearLocationEvent extends GoogleMapEvent {
  final bool isFromLocation;

  OnClearLocationEvent(this.isFromLocation);
}

class OnLoadDefaultLocationEvent extends GoogleMapEvent {
  final bool isFromLocation;
  final LatLng currentLatLng;

  OnLoadDefaultLocationEvent(this.isFromLocation, this.currentLatLng);
}

class OnLoadNewLocationEvent extends GoogleMapEvent {
  final Prediction prediction;
  final bool isFromLocation;

  OnLoadNewLocationEvent(this.prediction, this.isFromLocation);
}

class OnSendMessageBackEvent extends GoogleMapEvent {
  final String message;
  final User senderUser;
  final LatLng senderLatLng;

  OnSendMessageBackEvent(
    this.message,
    this.senderUser,
    this.senderLatLng,
  );
}

class OnLoadLocationFromPublicMessageEvent extends GoogleMapEvent {
  final String fromDescription;
  final String toDescription;
  final LatLng fromLatLng;
  final LatLng toLatLng;
  final String token;

  OnLoadLocationFromPublicMessageEvent(
    this.fromDescription,
    this.toDescription,
    this.fromLatLng,
    this.toLatLng,
    this.token,
  );
}

class OnCalculateDistanceEvent extends GoogleMapEvent {
  final LatLng startLatLng;
  final LatLng endLatLng;

  OnCalculateDistanceEvent(this.startLatLng, this.endLatLng);
}

class OnLoadLocationFromPrivateMessageEvent extends GoogleMapEvent {
  final String description;
  final LatLng latLng;

  OnLoadLocationFromPrivateMessageEvent(this.description, this.latLng);
}

class OnLoadCurrentLocationEvent extends GoogleMapEvent {
  final String phoneNumber;

  OnLoadCurrentLocationEvent(this.phoneNumber);
}

class OnLoadOrderRouteEvent extends GoogleMapEvent {
  final String fromDescription;
  final String toDescription;
  final LatLng fromLatLng;
  final LatLng toLatLng;

  OnLoadOrderRouteEvent(
    this.fromDescription,
    this.toDescription,
    this.fromLatLng,
    this.toLatLng,
  );
}

class OnClearMapEvent extends GoogleMapEvent {}
