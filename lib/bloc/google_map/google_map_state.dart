// import 'package:flutter_google_places/flutter_google_places.dart';

part of 'google_map_bloc.dart';

abstract class GoogleMapState extends Equatable {
  const GoogleMapState();
}

class GoogleMapInitial extends GoogleMapState {
  @override
  List<Object> get props => [];
}

class GoogleMapSelectedState extends GoogleMapState {
  final Prediction? prediction;
  final bool isFromLocation;

  const GoogleMapSelectedState(
    this.prediction,
    this.isFromLocation,
  );

  @override
  List<Object?> get props => [prediction, isFromLocation];
}

class GoogleMapNewLocationLoadedState extends GoogleMapState {
  final LatLng latLng;
  final bool isFromLocation;
  final Prediction? prediction;

  const GoogleMapNewLocationLoadedState(
    this.latLng,
    this.isFromLocation,
    this.prediction,
  );

  @override
  List<Object?> get props => [latLng, isFromLocation, prediction];
}

class GoogleMapLoadedState extends GoogleMapState {
  final List<Prediction> predictionList;

  const GoogleMapLoadedState(this.predictionList);

  @override
  List<Object?> get props => [predictionList];
}

class GoogleMapLoadingState extends GoogleMapState {
  @override
  List<Object?> get props => [];
}

class GoogleMapLocationClearedState extends GoogleMapState {
  final bool isFromLocation;

  const GoogleMapLocationClearedState(this.isFromLocation);

  @override
  List<Object?> get props => [isFromLocation];
}

class GoogleMapDefaultLocationLoadedState extends GoogleMapState {
  final bool isFromLocation;

  const GoogleMapDefaultLocationLoadedState(this.isFromLocation);

  @override
  List<Object?> get props => [isFromLocation];
}

class GoogleMapErrorState extends GoogleMapState {
  final String message;

  const GoogleMapErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class GoogleMapMessageSentBackState extends GoogleMapState {
  final String message;

  const GoogleMapMessageSentBackState(this.message);

  @override
  List<Object?> get props => [message];
}

class GoogleMapDirectionFromPublicMessageLoadedState extends GoogleMapState {
  final String fromDescription;
  final String toDescription;
  final LatLng fromLatLng;
  final LatLng toLatLng;

  const GoogleMapDirectionFromPublicMessageLoadedState(
    this.fromLatLng,
    this.toLatLng,
    this.fromDescription,
    this.toDescription,
  );

  @override
  List<Object?> get props =>
      [fromLatLng, toLatLng, fromDescription, toDescription];
}

class GoogleMapLocationFromPrivateMessageLoadedState extends GoogleMapState {
  final String description;
  final LatLng latLng;

  const GoogleMapLocationFromPrivateMessageLoadedState(
    this.description,
    this.latLng,
  );

  @override
  List<Object?> get props => [description, latLng];
}
