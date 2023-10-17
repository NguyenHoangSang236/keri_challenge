import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension LatLngConverter on LatLng {
  PointLatLng get toPointLatLng => PointLatLng(latitude, longitude);
}
