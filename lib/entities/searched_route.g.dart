// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'searched_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchedRoute _$SearchedRouteFromJson(Map<String, dynamic> json) =>
    SearchedRoute(
      MyLocation.fromJson(json['fromLocation'] as Map<String, dynamic>),
      MyLocation.fromJson(json['toLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchedRouteToJson(SearchedRoute instance) =>
    <String, dynamic>{
      'fromLocation': instance.fromLocation,
      'toLocation': instance.toLocation,
    };
