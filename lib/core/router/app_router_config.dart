import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

import '../../data/entities/user.dart';
import '../../view/screens/account_list_screen.dart';
import '../../view/screens/client_index_screen.dart';
import '../../view/screens/initial_loading_screen.dart';
import '../../view/screens/login_screen.dart';
import '../../view/screens/map_screen.dart';
import '../../view/screens/online_shipper_list_screen.dart';
import '../../view/screens/phone_verification_screen.dart';
import '../../view/screens/register_screen.dart';
import '../../view/screens/searching_screen.dart';
import '../../view/screens/shipper_index_screen.dart';
import '../../view/screens/shipper_service_screen.dart';
import 'app_router_path.dart';

part 'app_router_config.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: InitialLoadingRoute.page,
          path: AppRouterPath.initialLoading,
          initial: true,
        ),
        AutoRoute(
          page: MapRoute.page,
          path: AppRouterPath.googleMap,
        ),
        AutoRoute(
          page: RegisterRoute.page,
          path: AppRouterPath.register,
        ),
        AutoRoute(
          page: LoginRoute.page,
          path: AppRouterPath.login,
        ),
        AutoRoute(
          page: SearchingRoute.page,
          path: AppRouterPath.searching,
        ),
        AutoRoute(
          page: PhoneVerificationRoute.page,
          path: AppRouterPath.phoneVerification,
        ),
        AutoRoute(
          page: AccountListRoute.page,
          path: AppRouterPath.accountList,
        ),
        AutoRoute(
          page: ClientIndexRoute.page,
          path: AppRouterPath.clientIndex,
        ),
        AutoRoute(
          page: OnlineShipperRoute.page,
          path: AppRouterPath.onlineShipperList,
        ),
        AutoRoute(
          page: ShipperIndexRoute.page,
          path: AppRouterPath.shipperIndex,
        ),
        AutoRoute(
          page: ShipperServiceRoute.page,
          path: AppRouterPath.shipperService,
        ),
      ];
}
