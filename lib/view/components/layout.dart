import 'package:auto_route/auto_route.dart';
import 'package:dropdown_button3/dropdown_button3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/bloc/order/order_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_config.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';

class Layout extends StatefulWidget {
  const Layout({
    super.key,
    required this.body,
    required this.title,
    this.canComeBack = true,
  });

  final Widget body;
  final String title;
  final bool canComeBack;

  @override
  State<StatefulWidget> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final List<String> _clientRouteList = [
    AppRouterPath.clientIndex,
    AppRouterPath.login
  ];
  final List<String> _clientRouteNameList = ['Trang chủ', 'Đăng xuất'];

  void _onChangePage(String? path) {
    if (path != null && path.isNotEmpty) {
      if (path == AppRouterPath.clientIndex) {
        context.router.pushNamed(path);
      } else if (path == AppRouterPath.login) {
        context.read<GoogleMapBloc>().add(OnClearMapEvent());
        context.read<OrderBloc>().add(OnClearOrderEvent());
        context.read<AuthorBloc>().add(OnLogoutEvent());
        context.router.replaceAll([const LoginRoute()]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: !widget.canComeBack
            ? Container(
                margin: EdgeInsets.only(left: 10.width),
                child: Image.asset('assets/images/LoGo.png'),
              )
            : IconButton(
                onPressed: () => context.router.pop(),
                color: Colors.white,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 30.size,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
        leadingWidth: !widget.canComeBack ? 100.width : 40.width,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 17.size,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: Icon(
                Icons.list,
                size: 40.size,
                color: Theme.of(context).colorScheme.secondary,
              ),
              items: List.generate(
                _clientRouteList.length,
                (index) => DropdownMenuItem<String>(
                  value: _clientRouteList[index],
                  child: Text(_clientRouteNameList[index]),
                ),
              ),
              onChanged: _onChangePage,
              dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
              dropdownWidth: 160.width,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).colorScheme.secondary,
              ),
              dropdownElevation: 2,
              customItemsHeights: List<double>.filled(
                _clientRouteList.length,
                48,
              ),
            ),
          ),
          10.horizontalSpace,
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: widget.body,
    );
  }
}
