import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

import '../../entities/user.dart';
import '../../screens/login_screen.dart';
import '../../screens/map_screen.dart';
import '../../screens/phone_verification_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/searching_screen.dart';
import 'app_router_path.dart';

part 'app_router_config.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  AppRouter();

  @override
  List<AutoRoute> get routes => [
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
          initial: true,
        ),
        AutoRoute(
          page: SearchingRoute.page,
          path: AppRouterPath.searching,
        ),
        AutoRoute(
          page: PhoneVerificationRoute.page,
          path: AppRouterPath.phoneVerification,
        ),
      ];
}
