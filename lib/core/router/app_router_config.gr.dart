// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router_config.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AccountListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AccountListScreen(),
      );
    },
    ClientIndexRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ClientIndexScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    MapRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MapScreen(),
      );
    },
    PhoneVerificationRoute.name: (routeData) {
      final args = routeData.argsAs<PhoneVerificationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PhoneVerificationScreen(
          key: args.key,
          user: args.user,
        ),
      );
    },
    RegisterRoute.name: (routeData) {
      final args = routeData.argsAs<RegisterRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RegisterScreen(
          key: args.key,
          isShipper: args.isShipper,
        ),
      );
    },
    SearchingRoute.name: (routeData) {
      final args = routeData.argsAs<SearchingRouteArgs>(
          orElse: () => const SearchingRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SearchingScreen(
          key: args.key,
          isFromLocation: args.isFromLocation,
        ),
      );
    },
  };
}

/// generated route for
/// [AccountListScreen]
class AccountListRoute extends PageRouteInfo<void> {
  const AccountListRoute({List<PageRouteInfo>? children})
      : super(
          AccountListRoute.name,
          initialChildren: children,
        );

  static const String name = 'AccountListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ClientIndexScreen]
class ClientIndexRoute extends PageRouteInfo<void> {
  const ClientIndexRoute({List<PageRouteInfo>? children})
      : super(
          ClientIndexRoute.name,
          initialChildren: children,
        );

  static const String name = 'ClientIndexRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MapScreen]
class MapRoute extends PageRouteInfo<void> {
  const MapRoute({List<PageRouteInfo>? children})
      : super(
          MapRoute.name,
          initialChildren: children,
        );

  static const String name = 'MapRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PhoneVerificationScreen]
class PhoneVerificationRoute extends PageRouteInfo<PhoneVerificationRouteArgs> {
  PhoneVerificationRoute({
    Key? key,
    required User user,
    List<PageRouteInfo>? children,
  }) : super(
          PhoneVerificationRoute.name,
          args: PhoneVerificationRouteArgs(
            key: key,
            user: user,
          ),
          initialChildren: children,
        );

  static const String name = 'PhoneVerificationRoute';

  static const PageInfo<PhoneVerificationRouteArgs> page =
      PageInfo<PhoneVerificationRouteArgs>(name);
}

class PhoneVerificationRouteArgs {
  const PhoneVerificationRouteArgs({
    this.key,
    required this.user,
  });

  final Key? key;

  final User user;

  @override
  String toString() {
    return 'PhoneVerificationRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [RegisterScreen]
class RegisterRoute extends PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    Key? key,
    required bool isShipper,
    List<PageRouteInfo>? children,
  }) : super(
          RegisterRoute.name,
          args: RegisterRouteArgs(
            key: key,
            isShipper: isShipper,
          ),
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<RegisterRouteArgs> page =
      PageInfo<RegisterRouteArgs>(name);
}

class RegisterRouteArgs {
  const RegisterRouteArgs({
    this.key,
    required this.isShipper,
  });

  final Key? key;

  final bool isShipper;

  @override
  String toString() {
    return 'RegisterRouteArgs{key: $key, isShipper: $isShipper}';
  }
}

/// generated route for
/// [SearchingScreen]
class SearchingRoute extends PageRouteInfo<SearchingRouteArgs> {
  SearchingRoute({
    Key? key,
    bool isFromLocation = true,
    List<PageRouteInfo>? children,
  }) : super(
          SearchingRoute.name,
          args: SearchingRouteArgs(
            key: key,
            isFromLocation: isFromLocation,
          ),
          initialChildren: children,
        );

  static const String name = 'SearchingRoute';

  static const PageInfo<SearchingRouteArgs> page =
      PageInfo<SearchingRouteArgs>(name);
}

class SearchingRouteArgs {
  const SearchingRouteArgs({
    this.key,
    this.isFromLocation = true,
  });

  final Key? key;

  final bool isFromLocation;

  @override
  String toString() {
    return 'SearchingRouteArgs{key: $key, isFromLocation: $isFromLocation}';
  }
}
