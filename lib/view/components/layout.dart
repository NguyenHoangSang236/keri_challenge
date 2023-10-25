import 'package:dropdown_button3/dropdown_button3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';

class Layout extends StatefulWidget {
  const Layout({
    super.key,
    required this.body,
    required this.title,
  });

  final Widget body;
  final String title;

  @override
  State<StatefulWidget> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final List<String> _clientRouteList = [
    AppRouterPath.clientIndex,
    AppRouterPath.login
  ];
  final List<String> _clientRouteNameList = ['Trang chủ', 'Đăng xuất'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Container(
          margin: EdgeInsets.only(left: 10.width),
          child: Image.asset('assets/images/LoGo.png'),
        ),
        leadingWidth: 100.width,
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
              onChanged: (value) {
                print(value);
              },
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
