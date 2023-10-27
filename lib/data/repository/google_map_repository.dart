import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:keri_challenge/core/failure/failure.dart';

import '../../main.dart';

class GoogleMapRepository {
  Future<Either<Failure, List<Prediction>>> getLocationData(String text) async {
    http.Response response;

    response = await http.get(
      Uri.parse(
        "http://mvs.bslmeiyu.com/api/v1/config/place-api-autocomplete?search_text=$text",
      ),
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      List<Prediction> predictionList = [];

      data['predictions'].forEach(
          (prediction) => predictionList.add(Prediction.fromJson(prediction)));

      return Right(predictionList);
    } else {
      return const Left(ApiFailure('Seaching Api Error!'));
    }
  }

  Future<Either<Failure, PlacesDetailsResponse>> getDetailsByPlaceId(
    String placeId,
  ) async {
    try {
      GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: apiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );

      PlacesDetailsResponse details = await places.getDetailsByPlaceId(
        placeId,
      );

      return Right(details);
    } catch (e, stackTrace) {
      debugPrint('Catch error: ${e.toString()} \n ${stackTrace.toString()}');
      return Left(ApiFailure(e.toString()));
    }
  }
}
