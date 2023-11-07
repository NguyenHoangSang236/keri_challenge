import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart'
    as flutter_polyline_points;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/core/extension/latLng_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/extension/pointLatLng_extension.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/screens/searching_screen.dart';

import '../../bloc/authorization/author_bloc.dart';
import '../../data/entities/user.dart';
import '../../data/enum/local_storage_enum.dart';
import '../../main.dart';
import '../../services/firebase_message_service.dart';
import '../../services/local_storage_service.dart';
import '../../util/ui_render.dart';

@RoutePage()
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  final TextEditingController _messageBackController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();

  // on below line we have specified camera position
  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  // on below line we have created the list of markers
  final List<Marker> _markers = <Marker>[
    // const Marker(
    //   markerId: MarkerId('1'),
    //   position: LatLng(20.42796133580664, 75.885749655962),
    //   infoWindow: InfoWindow(
    //     title: 'My Position',
    //   ),
    // ),
  ];

  List<LatLng> polylineLatLngList = [];
  final PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylinesMap = {};
  late LatLng currentLatLng;

  void _clearAllMarkers() {
    setState(() {
      _markers.clear();
    });
  }

  void _clearMarker(bool isFromLocation) {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        setState(() {
          _markers.removeWhere(
            (marker) => isFromLocation
                ? marker.markerId.value == 'From Location'
                : marker.markerId.value == 'To Location',
          );

          polylineLatLngList = [];
          polylinesMap = {};
        });
      },
    );
  }

  void _onPressTextBox(bool isFromLocation) {
    context.router.pushWidget(
      SearchingScreen(isFromLocation: isFromLocation),
    );
  }

  void _onPressRemoveLocationButton(bool isFromLocation) {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        context.read<GoogleMapBloc>().add(
              OnClearLocationEvent(isFromLocation),
            );
      },
    );
  }

  Future<void> _onPressPinLocationButton(bool isFromLocation) async {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        Prediction prediction = isFromLocation
            ? context.read<GoogleMapBloc>().currentSelectedFromPrediction
            : context.read<GoogleMapBloc>().currentSelectedToPrediction;

        if (prediction.description == 'Tìm điểm đến...' ||
            prediction.description == 'Tìm điểm đi...') {
          context.read<GoogleMapBloc>().add(
                OnLoadDefaultLocationEvent(
                  isFromLocation,
                  currentLatLng,
                ),
              );
        } else {
          LatLng latLng = isFromLocation
              ? context
                  .read<GoogleMapBloc>()
                  .currentSelectedFromPointLatLng!
                  .toLatLng
              : context
                  .read<GoogleMapBloc>()
                  .currentSelectedToPointLatLng!
                  .toLatLng;

          _addMarkerAndAnimateCameraToPosition(
            latLng: latLng,
            isFromLocation: isFromLocation,
          );

          debugPrint('Location: ${prediction.description}');
          debugPrint(
              'ID: ${isFromLocation == true ? 'From Location' : 'To Location'}');
          debugPrint('latitude: ${latLng.latitude}');
          debugPrint('longitude: ${latLng.longitude}');
        }
      },
    );
  }

  void _animateCameraToPosition(LatLng latLng) async {
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 14,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  void _addMarkerOnMap({
    required LatLng latLng,
    bool isFromLocation = true,
  }) async {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(isFromLocation ? 'From Location' : 'To Location'),
          position: latLng,
          infoWindow: const InfoWindow(
            title: 'Searching Location',
          ),
        ),
      );
    });
  }

  void _addMarkerAndAnimateCameraToPosition({
    required LatLng latLng,
    bool isFromLocation = true,
  }) async {
    _addMarkerOnMap(latLng: latLng, isFromLocation: isFromLocation);

    _animateCameraToPosition(latLng);
  }

  void _onPressShowDirectionButton() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        PointLatLng? fromPointLatLng =
            context.read<GoogleMapBloc>().currentSelectedFromPointLatLng;

        PointLatLng? toPointLatLng =
            context.read<GoogleMapBloc>().currentSelectedToPointLatLng;

        if (fromPointLatLng == null && toPointLatLng == null) {
          UiRender.showSnackBar(context, 'Must have one location at least!');
        } else if (fromPointLatLng != null && toPointLatLng != null) {
          Prediction? startPre =
              context.read<GoogleMapBloc>().currentSelectedFromPrediction;
          Prediction? endPre =
              context.read<GoogleMapBloc>().currentSelectedToPrediction;

          _showDirection(
            start: fromPointLatLng,
            end: toPointLatLng,
            startPre: startPre,
            endPre: endPre,
          );
        } else {
          UiRender.showConfirmDialog(
            context,
            '',
            'Please press on PIN icon of the location which you left empty to get your current location!',
          );
        }
      },
    );
  }

  void _showDirection({
    required PointLatLng start,
    required PointLatLng end,
    Prediction? startPre,
    Prediction? endPre,
    bool needMessage = true,
  }) async {
    // Generating the list of coordinates to be used for drawing the polylines
    // PolylineResult result = PolylineResult();
    context.read<GoogleMapBloc>().add(
          OnCalculateDistanceEvent(start.toLatLng, end.toLatLng),
        );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Google Maps API Key
      start,
      end,
      travelMode: flutter_polyline_points.TravelMode.transit,
    );

    setState(() {
      if (needMessage) {
        sendMessage(
          startPre: startPre,
          endPre: endPre,
          startLatLng: start,
          endLatLng: end,
        );
      }

      // Adding the coordinates to the list
      if (result.points.isNotEmpty) {
        debugPrint('Point list has ${result.points.length} points');

        for (var point in result.points) {
          debugPrint('${point.longitude}, ${point.latitude}');

          polylineLatLngList.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        debugPrint('Point list is empty');
      }

      // Defining an ID
      PolylineId id = const PolylineId('poly');

      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineLatLngList,
        width: 4,
      );

      // Adding the polyline to the map
      polylinesMap[id] = polyline;
    });
  }

  void sendMessage({
    Prediction? startPre,
    Prediction? endPre,
    required PointLatLng startLatLng,
    required PointLatLng endLatLng,
  }) async {
    User user = context.read<AuthorBloc>().currentUser!;

    FirebaseMessageService.sendMessage(
      title: 'Notice !!',
      topic: '/topics/all',
      content:
          '${user.fullName} is finding a way from ${startPre?.description!.contains('My Location') == false ? startPre?.description : 'Position of ${user.fullName}'} to ${endPre?.description!.contains('My Location') == false ? endPre?.description : 'Position of ${user.fullName}'}',
      data: {
        'fromPhoneToken': await LocalStorageService.getLocalStorageData(
          LocalStorageEnum.phoneToken.name,
        ) as String,
        'startDes': startPre?.description!.contains('My Location') == false
            ? startPre?.description
            : 'Location of ${user.fullName}',
        'endDes': endPre?.description!.contains('My Location') == false
            ? endPre?.description
            : 'Location of ${user.fullName}',
        'startLat': startLatLng.latitude.toString(),
        'startLng': startLatLng.longitude.toString(),
        'endLat': endLatLng.latitude.toString(),
        'endLng': endLatLng.longitude.toString(),
      },
    );
  }

  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      debugPrint("ERROR: $error");
    });

    return await Geolocator.getCurrentPosition();
  }

  void _comeback() {
    LatLng? start =
        context.read<GoogleMapBloc>().currentSelectedFromPointLatLng?.toLatLng;
    LatLng? end =
        context.read<GoogleMapBloc>().currentSelectedToPointLatLng?.toLatLng;

    if (start != null && end != null) {
      context.read<GoogleMapBloc>().add(
            OnCalculateDistanceEvent(start, end),
          );
    }

    context.router.pop();
  }

  void _confirmShippingLocation() {
    PointLatLng? from =
        context.read<GoogleMapBloc>().currentSelectedFromPointLatLng;

    PointLatLng? to =
        context.read<GoogleMapBloc>().currentSelectedToPointLatLng;

    if (from != null && to != null) {
      context.read<GoogleMapBloc>().add(
            OnCalculateDistanceEvent(
              context
                  .read<GoogleMapBloc>()
                  .currentSelectedFromPointLatLng!
                  .toLatLng,
              context
                  .read<GoogleMapBloc>()
                  .currentSelectedToPointLatLng!
                  .toLatLng,
            ),
          );

      context.router.pop();
    } else {
      UiRender.showDialog(context, '', 'Vui lòng chọn điểm đi và điểm đến');
    }
  }

  @override
  void initState() {
    currentLatLng = context.read<GoogleMapBloc>().currentPointLatLng!.toLatLng;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _comeback,
          color: Colors.white,
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30.size,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        leadingWidth: 40.width,
        toolbarHeight: 180.height,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Vinaship",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            searchingButton(true),
            searchingButton(false),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _onPressShowDirectionButton,
            color: Colors.white,
            icon: Icon(
              Icons.directions,
              size: 40.size,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition: _kGoogle,
              markers: Set<Marker>.of(_markers),
              mapType: MapType.terrain,
              myLocationEnabled: true,
              polylines: Set<Polyline>.of(polylinesMap.values),
              compassEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20.width,
            child: GradientElevatedButton(
              text: 'Xác nhận địa chỉ giao hàng',
              buttonWidth: MediaQuery.of(context).size.width - 40.width,
              buttonHeight: 50.height,
              buttonMargin: EdgeInsets.symmetric(
                vertical: 30.height,
              ),
              onPress: _confirmShippingLocation,
            ),
          ),
        ],
      ),
    );
  }

  Widget searchingButton(bool isFromLocation) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _onPressTextBox(isFromLocation),
            child: Container(
              // width: MediaQuery.of().size.width,
              margin: EdgeInsets.only(top: 10.height),
              padding: EdgeInsets.symmetric(
                vertical: 10.height,
                horizontal: 5.width,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.radius),
              ),
              child: BlocConsumer<GoogleMapBloc, GoogleMapState>(
                listener: (context, state) async {
                  if (state is GoogleMapNewLocationLoadedState) {
                    _addMarkerAndAnimateCameraToPosition(
                      latLng: state.latLng,
                      isFromLocation: state.isFromLocation,
                    );
                  } else if (state is GoogleMapCurrentLocationLoadedState) {
                    setState(() {
                      currentLatLng = state.currentLatLng;

                      _animateCameraToPosition(currentLatLng);
                    });
                  } else if (state is GoogleMapLocationClearedState) {
                    _clearMarker(state.isFromLocation);
                  } else if (state is GoogleMapMessageSentBackState) {
                    UiRender.showSnackBar(context, state.message);
                  } else if (state
                      is GoogleMapDirectionFromPublicMessageLoadedState) {
                    _addMarkerOnMap(
                      latLng: state.fromLatLng,
                      isFromLocation: true,
                    );

                    _addMarkerAndAnimateCameraToPosition(
                      latLng: state.toLatLng,
                      isFromLocation: false,
                    );

                    _showDirection(
                      start: state.fromLatLng.toPointLatLng,
                      end: state.toLatLng.toPointLatLng,
                      needMessage: false,
                    );

                    if (isFromLocation) {
                      String? message =
                          await UiRender.showSingleTextFieldDialog(
                                  context, _messageBackController,
                                  hintText: 'Type your message here...')
                              .then((value) {
                        if (value.isNotEmpty) {
                          context.read<GoogleMapBloc>().add(
                                OnSendMessageBackEvent(
                                  value,
                                  context.read<AuthorBloc>().currentUser!,
                                  currentLatLng,
                                ),
                              );
                        }

                        return null;
                      });
                    }
                  } else if (state
                      is GoogleMapLocationFromPrivateMessageLoadedState) {
                    _onPressPinLocationButton(false);
                  } else if (state is GoogleMapErrorState) {
                    UiRender.showDialog(context, 'Lỗi', state.message);
                  } else if (state is GoogleMapOrderDirectionLoadedState) {
                    _addMarkerAndAnimateCameraToPosition(
                      latLng: state.fromLatLng,
                      isFromLocation: true,
                    );

                    _addMarkerAndAnimateCameraToPosition(
                      latLng: state.toLatLng,
                      isFromLocation: false,
                    );

                    _showDirection(
                      start: state.fromLatLng.toPointLatLng,
                      end: state.toLatLng.toPointLatLng,
                      needMessage: false,
                    );
                  }
                },
                builder: (context, state) {
                  String? currentLocation = isFromLocation
                      ? context
                          .read<GoogleMapBloc>()
                          .currentSelectedFromPrediction
                          .description
                      : context
                          .read<GoogleMapBloc>()
                          .currentSelectedToPrediction
                          .description;

                  if (state is GoogleMapSelectedState) {
                    if (state.isFromLocation == isFromLocation) {
                      currentLocation =
                          state.prediction?.description ?? 'UNDEFINED';
                    }
                  }
                  if (state is GoogleMapNewLocationLoadedState) {
                    if (state.isFromLocation == isFromLocation) {
                      currentLocation = state.prediction?.description;
                    }
                  } else if (state is GoogleMapLocationClearedState) {
                    if (state.isFromLocation == isFromLocation) {
                      currentLocation = currentLocation = isFromLocation
                          ? context
                              .read<GoogleMapBloc>()
                              .currentSelectedFromPrediction
                              .description
                          : context
                              .read<GoogleMapBloc>()
                              .currentSelectedToPrediction
                              .description;
                    }
                  } else if (state
                      is GoogleMapDirectionFromPublicMessageLoadedState) {
                    currentLocation = isFromLocation
                        ? state.fromDescription
                        : state.toDescription;
                  } else if (state
                      is GoogleMapLocationFromPrivateMessageLoadedState) {
                    if (!isFromLocation) {
                      currentLocation = state.description;
                    }
                  } else if (state is GoogleMapOrderDirectionLoadedState) {
                    currentLocation = isFromLocation
                        ? state.fromDescription
                        : state.toDescription;
                  }

                  return Text(
                    currentLocation ?? '---',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.size,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(
          width: 35.size,
          height: 35.size,
          child: IconButton(
            onPressed: () => _onPressRemoveLocationButton(isFromLocation),
            icon: Icon(
              Icons.clear,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        SizedBox(
          width: 35.size,
          height: 35.size,
          child: IconButton(
            onPressed: () => _onPressPinLocationButton(isFromLocation),
            icon: Icon(
              Icons.pin_drop_sharp,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
