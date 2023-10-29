import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:keri_challenge/core/extension/latLng_extenstion.dart';
import 'package:keri_challenge/core/extension/pointLatLng_extension.dart';
import 'package:keri_challenge/core/extension/position_extension.dart';
import 'package:keri_challenge/services/firebase_message_service.dart';

import '../../data/entities/user.dart';
import '../../data/enum/local_storage_enum.dart';
import '../../data/repository/google_map_repository.dart';
import '../../services/local_storage_service.dart';

part 'google_map_event.dart';
part 'google_map_state.dart';

class GoogleMapBloc extends Bloc<GoogleMapEvent, GoogleMapState> {
  final GoogleMapRepository _googleMapRepository;
  String? selectedPhoneTokenFromMessage;
  List<Prediction> predictionList = [];
  double distance = 0;

  /// for product
  Prediction currentSelectedFromPrediction =
      Prediction(description: 'Tìm điểm đi...');
  Prediction currentSelectedToPrediction =
      Prediction(description: 'Tìm điểm đến...');
  PointLatLng? currentSelectedFromPointLatLng;
  PointLatLng? currentSelectedToPointLatLng;

  /// for test
  PointLatLng testPoint1 =
      const PointLatLng(10.886672987557565, 106.59042876381808);
  PointLatLng testPoint2 =
      const PointLatLng(10.868814409965742, 106.65022524592496);

  GoogleMapBloc(this._googleMapRepository) : super(GoogleMapInitial()) {
    on<OnLoadPredictionsEvent>((event, emit) async {
      emit(GoogleMapLoadingState());

      try {
        final response = await _googleMapRepository.getLocationData(event.text);

        response.fold(
          (failure) => emit(GoogleMapErrorState(failure.message)),
          (data) {
            predictionList = data;

            emit(GoogleMapLoadedState(data));
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Catch error: ${e.toString()} \n ${stackTrace.toString()}');
        emit(GoogleMapErrorState(e.toString()));
      }
    });

    on<OnLoadNewLocationEvent>((event, emit) async {
      emit(GoogleMapLoadingState());

      try {
        /// for production
        final response = await _googleMapRepository.getDetailsByPlaceId(
          event.prediction.placeId!,
        );

        response.fold(
          (failure) => emit(GoogleMapErrorState(failure.message)),
          (details) {
            if (details.isOkay) {
              final location = details.result.geometry?.location;
              final latLng = LatLng(
                location!.lat,
                location.lng,
              );

              if (event.isFromLocation) {
                currentSelectedFromPrediction = event.prediction;
                currentSelectedFromPointLatLng = PointLatLng(
                  location.lat,
                  location.lng,
                );
              } else {
                currentSelectedToPrediction = event.prediction;
                currentSelectedToPointLatLng = PointLatLng(
                  location.lat,
                  location.lng,
                );
              }

              emit(GoogleMapNewLocationLoadedState(
                latLng,
                event.isFromLocation,
                event.prediction,
              ));
            } else {
              emit(GoogleMapErrorState(details.result.name));
            }
          },
        );
      } catch (e, stackTrace) {
        if (e.toString().contains(
            'type \'Null\' is not a subtype of type \'Map<String, dynamic>\' in type cast')) {
          /// for test
          if (event.isFromLocation) {
            currentSelectedFromPointLatLng = testPoint1;
            currentSelectedFromPrediction = event.prediction;

            emit(GoogleMapNewLocationLoadedState(
              testPoint1.toLatLng,
              event.isFromLocation,
              event.prediction,
            ));
          } else {
            currentSelectedToPointLatLng = testPoint2;
            currentSelectedToPrediction = event.prediction;

            emit(GoogleMapNewLocationLoadedState(
              testPoint2.toLatLng,
              event.isFromLocation,
              event.prediction,
            ));
          }
        } else {
          debugPrint(
            'Catch error: ${e.toString()} \n ${stackTrace.toString()}',
          );
          emit(GoogleMapErrorState(e.toString()));
        }
      }
    });

    on<OnClearLocationEvent>((event, emit) {
      if (event.isFromLocation) {
        currentSelectedFromPrediction =
            Prediction(description: 'Tìm điểm đến...');
        currentSelectedFromPointLatLng = null;
      } else {
        currentSelectedToPrediction = Prediction(description: 'Tìm điểm đi...');
        currentSelectedToPointLatLng = null;
      }
      distance = 0;

      emit(GoogleMapLocationClearedState(event.isFromLocation));
    });

    on<OnCalculateDistanceEvent>((event, emit) {
      distance = Geolocator.distanceBetween(
            event.startLatLng.latitude,
            event.startLatLng.longitude,
            event.endLatLng.latitude,
            event.endLatLng.longitude,
          ) /
          1000;

      emit(GoogleMapDistanceCalculatedState(distance));
    });

    on<OnLoadDefaultLocationEvent>((event, emit) async {
      List<Placemark> addresses = await placemarkFromCoordinates(
        event.currentPosition.latitude,
        event.currentPosition.longitude,
      );

      String currentAddress =
          '${addresses.first.street}, ${addresses.first.subAdministrativeArea}, ${addresses.first.administrativeArea}, ${addresses.first.country}';

      if (event.isFromLocation) {
        currentSelectedFromPrediction = Prediction(
          description: currentAddress,
        );
        currentSelectedFromPointLatLng = event.currentPosition.toPointLatLng;
      } else {
        currentSelectedToPrediction = Prediction(
          description: currentAddress,
        );
        currentSelectedToPointLatLng = event.currentPosition.toPointLatLng;
      }

      emit(GoogleMapNewLocationLoadedState(
        event.currentPosition.toLatLng,
        event.isFromLocation,
        Prediction(description: currentAddress),
      ));
    });

    on<OnLoadLocationFromPublicMessageEvent>((event, emit) {
      selectedPhoneTokenFromMessage = event.token;

      currentSelectedFromPrediction = Prediction(
        description: event.fromDescription,
      );
      currentSelectedToPrediction = Prediction(
        description: event.toDescription,
      );
      currentSelectedFromPointLatLng = event.fromLatLng.toPointLatLng;
      currentSelectedToPointLatLng = event.toLatLng.toPointLatLng;

      emit(
        GoogleMapDirectionFromPublicMessageLoadedState(
          event.fromLatLng,
          event.toLatLng,
          event.fromDescription,
          event.toDescription,
        ),
      );
    });

    on<OnSendMessageBackEvent>((event, emit) async {
      try {
        if (event.message.isNotEmpty) {
          debugPrint(
              'Send message back from ${await LocalStorageService.getLocalStorageData(LocalStorageEnum.phoneToken.name) as String} to $selectedPhoneTokenFromMessage ');

          FirebaseMessageService.sendMessage(
            title: 'You have message from ${event.senderUser.fullName}',
            content: event.message,
            data: {
              'fromPhoneToken': await LocalStorageService.getLocalStorageData(
                LocalStorageEnum.phoneToken.name,
              ) as String,
              'senderDes': 'Location of ${event.senderUser.fullName}',
              'senderLat': event.senderLatLng.latitude.toString(),
              'senderLng': event.senderLatLng.longitude.toString(),
              'message': event.message,
            },
            receiverToken: selectedPhoneTokenFromMessage,
          );

          emit(const GoogleMapMessageSentBackState(
            'Your message has just been sent',
          ));
        }
      } catch (e, stackTrace) {
        debugPrint('Catch error: ${e.toString()} \n ${stackTrace.toString()}');
        emit(GoogleMapErrorState(e.toString()));
      }
    });

    on<OnLoadLocationFromPrivateMessageEvent>((event, emit) {
      currentSelectedToPrediction = Prediction(
        description: event.description,
      );
      currentSelectedToPointLatLng = event.latLng.toPointLatLng;

      emit(GoogleMapLocationFromPrivateMessageLoadedState(
        event.description,
        event.latLng,
      ));
    });
  }
}
