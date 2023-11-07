import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/bloc/order/order_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/util/value_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/entities/user.dart';

class ShipperListComponent extends StatefulWidget {
  const ShipperListComponent({super.key, required this.shipper});

  final User shipper;

  @override
  State<StatefulWidget> createState() => _ShipperListComponentState();
}

class _ShipperListComponentState extends State<ShipperListComponent> {
  bool _isSelected = false;
  void _onSelectShipper() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _forwardOrder() {
    context
        .read<OrderBloc>()
        .add(OnForwardOrderEvent(widget.shipper.phoneNumber));
  }

  @override
  void initState() {
    if (ValueRender.currentUser!.currentLocation != null) {
      context.read<GoogleMapBloc>().add(
            OnCalculateDistanceEvent(
              LatLng(
                ValueRender.currentUser!.currentLocation!.latitude,
                ValueRender.currentUser!.currentLocation!.longitude,
              ),
              LatLng(
                widget.shipper.currentLocation!.latitude,
                widget.shipper.currentLocation!.longitude,
              ),
            ),
          );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoogleMapBloc, GoogleMapState>(
      builder: (context, state) {
        if (state is GoogleMapLoadingState) {
          return UiRender.loadingCircle(context);
        } else if (state is GoogleMapDistanceCalculatedState) {
          double distance = state.distance;

          return GestureDetector(
            onTap: _onSelectShipper,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    widget.shipper.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(widget.shipper.phoneNumber),
                  trailing: Text('${distance.format}km'),
                ),
                AnimatedContainer(
                  height: _isSelected ? 70.height : 0,
                  width: MediaQuery.of(context).size.width,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GradientElevatedButton(
                        text: 'Gọi ngay',
                        buttonWidth: 150.width,
                        buttonHeight: 40.height,
                        buttonMargin: EdgeInsets.zero,
                        onPress: () =>
                            _makePhoneCall(widget.shipper.phoneNumber),
                      ),
                      GradientElevatedButton(
                        text: 'Chuyển đơn',
                        buttonWidth: 150.width,
                        buttonHeight: 40.height,
                        buttonMargin: EdgeInsets.zero,
                        onPress: _forwardOrder,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
