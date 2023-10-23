import 'package:json_annotation/json_annotation.dart';

part 'my_location.g.dart';

@JsonSerializable()
class MyLocation {
  String placeId;
  double latitude;
  double longitude;
  String description;
  String distance;

  MyLocation(
    this.placeId,
    this.latitude,
    this.longitude,
    this.description,
    this.distance,
  );

  factory MyLocation.fromJson(Map<String, dynamic> json) =>
      _$MyLocationFromJson(json);

  Map<String, dynamic> toJson() => _$MyLocationToJson(this);

  @override
  String toString() {
    return '{placeId: $placeId, latitude: $latitude, longitude: $longitude, description: $description, distance: $distance}';
  }
}
