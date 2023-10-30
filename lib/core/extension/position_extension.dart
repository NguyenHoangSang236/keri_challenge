import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension PositionConverter on Position {
  LatLng get toLatLng => LatLng(latitude, longitude);
  PointLatLng get toPointLatLng => PointLatLng(latitude, longitude);
  GeoPoint get toGeoPoint => GeoPoint(latitude, longitude);
}
