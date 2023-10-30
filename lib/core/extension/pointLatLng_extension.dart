import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension PointLatLngConverter on PointLatLng {
  LatLng get toLatLng => LatLng(latitude, longitude);
  GeoPoint get toGeoPoint => GeoPoint(latitude, longitude);
}
