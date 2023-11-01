import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keri_challenge/core/router/app_router_config.dart';

import '../../bloc/appConfig/app_config_bloc.dart';
import '../../bloc/authorization/author_bloc.dart';
import '../../bloc/google_map/google_map_bloc.dart';
import '../../bloc/order/order_bloc.dart';
import '../../core/router/app_router_path.dart';
import '../../data/enum/local_storage_enum.dart';
import '../../services/firebase_message_service.dart';
import '../../services/local_storage_service.dart';

@RoutePage()
class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _InitialLoadingState();
}

class _InitialLoadingState extends State<InitialLoadingScreen> {
  String _savedUserName = '';
  String _savedPassword = '';

  Future<void> _loginEvent() async {
    _savedUserName = await LocalStorageService.getLocalStorageData(
      LocalStorageEnum.phoneNumber.name,
    ) as String;
    _savedPassword = await LocalStorageService.getLocalStorageData(
      LocalStorageEnum.password.name,
    ) as String;

    context.read<AuthorBloc>().add(
          OnLoginEvent(
            _savedUserName,
            _savedPassword,
          ),
        );
  }

  @override
  void initState() {
    context.read<AppConfigBloc>().add(OnLoadAppConfigEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseMessageService(context).initNotifications();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loginEvent(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: MultiBlocListener(
              listeners: [
                BlocListener<OrderBloc, OrderState>(
                  listener: (context, state) {
                    if (state is ShippingOrderLoadedState) {
                      context.router
                          .replaceAll([ShipperIndexRoute(initialTabIndex: 0)]);
                    } else if (state is OrderErrorState) {
                      context.router
                          .replaceAll([ShipperIndexRoute(initialTabIndex: 1)]);
                    }
                  },
                ),
                BlocListener<AuthorBloc, AuthorState>(
                  listener: (context, authenState) {
                    if (authenState is AuthorLoggedInState) {
                      if (authenState.user.role == 'client') {
                        context.router.replaceAll([const ClientIndexRoute()]);
                      } else if (authenState.user.role == 'shipper') {
                        context.read<OrderBloc>().add(
                              OnLoadShippingOrderEvent(
                                authenState.user.phoneNumber,
                              ),
                            );
                        context.read<GoogleMapBloc>().add(
                              OnLoadCurrentLocationEvent(
                                authenState.user.phoneNumber,
                              ),
                            );
                      } else if (authenState.user.role == 'admin') {}
                    } else if (authenState is AuthorErrorState) {
                      context.router.replaceNamed(AppRouterPath.login);
                    }
                  },
                ),
              ],
              child: Center(
                child: Image.asset(
                  'assets/images/LoGo.png',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
