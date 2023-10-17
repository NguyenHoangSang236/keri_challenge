import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:keri_challenge/core/failure/Failure.dart';

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
      return Left(ApiFailure('Seaching Api Error!'));
    }
  }
}
