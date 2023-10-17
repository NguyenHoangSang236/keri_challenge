import 'package:json_annotation/json_annotation.dart';
import 'package:keri_challenge/entities/my_location.dart';

part 'searched_route.g.dart';

@JsonSerializable()
class SearchedRoute {
  MyLocation fromLocation;
  MyLocation toLocation;

  SearchedRoute(this.fromLocation, this.toLocation);

  factory SearchedRoute.fromJson(Map<String, dynamic> json) =>
      _$SearchedRouteFromJson(json);

  Map<String, dynamic> toJson() => _$SearchedRouteToJson(this);

  @override
  String toString() {
    return '{fromLocation: ${fromLocation.toJson()}, toLocation: ${toLocation.toJson()}}';
  }
}
