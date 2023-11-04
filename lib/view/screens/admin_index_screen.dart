import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/account/account_bloc.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/enum/role_enum.dart';
import 'package:keri_challenge/view/components/layout.dart';

import '../../data/entities/user.dart';
import '../../util/ui_render.dart';
import '../components/gradient_button.dart';

@RoutePage()
class AdminIndexScreen extends StatefulWidget {
  const AdminIndexScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AdminIndexScreenState();
}

class _AdminIndexScreenState extends State<AdminIndexScreen> {
  final TextEditingController _clientListController = TextEditingController();
  final TextEditingController _shipperListController = TextEditingController();

  void _increaseUserListLimit(String role, TextEditingController controller) {
    setState(() {
      int limit = int.parse(controller.text);
      limit++;
      controller.text = limit.toString();

      context.read<AccountBloc>().add(OnLoadUserListEvent(role, limit));
    });
  }

  void _decreaseUserListLimit(String role, TextEditingController controller) {
    setState(() {
      int limit = int.parse(controller.text);

      if (limit > 1) {
        limit--;
        controller.text = limit.toString();

        context.read<AccountBloc>().add(OnLoadUserListEvent(role, limit));
      }
    });
  }

  void _changeUserListLimit(String role, String value) {
    setState(() {
      if (value.isNotEmpty) {
        int limit = int.parse(value);

        if (limit > 0) {
          _clientListController.text = limit.toString();

          context.read<AccountBloc>().add(OnLoadUserListEvent(role, limit));
        }
      }
    });
  }

  void _onLongPressDataRow(User user) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Thông tin người dùng'),
          content: _userInfo(user),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop();
              },
              isDefaultAction: true,
              child: const Text('Xác nhận'),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _clientListController.text = '10';
    _shipperListController.text = '10';

    context.read<AccountBloc>()
      ..add(OnLoadUserListEvent(
          RoleEnum.client.name,
          int.parse(
            _clientListController.text,
          )))
      ..add(OnLoadUserListEvent(
          RoleEnum.shipper.name,
          int.parse(
            _clientListController.text,
          )));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Trang chủ',
      canComeBack: false,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
              tabAlignment: TabAlignment.fill,
              padding: EdgeInsets.symmetric(
                vertical: 5.height,
                horizontal: 5.width,
              ),
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.hail_outlined,
                    size: 33.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      'Khách hàng',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.directions_bike_sharp,
                    size: 33.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      'Shipper',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _userList(RoleEnum.client, _clientListController),
                  _userList(RoleEnum.shipper, _shipperListController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userList(RoleEnum roleEnum, TextEditingController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                15.horizontalSpace,
                const Text('Xem '),
                GradientElevatedButton(
                  text: '-',
                  buttonHeight: 30.size,
                  textSize: 18.size,
                  buttonWidth: 30.size,
                  buttonMargin: EdgeInsets.zero,
                  onPress: () => _decreaseUserListLimit(
                    roleEnum.name,
                    controller,
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    width: 60.width,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: controller,
                      showCursor: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) => _changeUserListLimit(
                        roleEnum.name,
                        value,
                      ),
                    ),
                  ),
                ),
                GradientElevatedButton(
                  text: '+',
                  textSize: 18.size,
                  buttonHeight: 30.size,
                  buttonWidth: 30.size,
                  buttonMargin: EdgeInsets.zero,
                  onPress: () => _increaseUserListLimit(
                    roleEnum.name,
                    controller,
                  ),
                ),
                5.horizontalSpace,
                const Text('dòng'),
              ],
            ),
            20.verticalSpace,
            Center(
              child: Text(
                'Nhẫn và giữ để xem thông tin chi tiết đơn hàng của bạn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.size,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            20.verticalSpace,
            roleEnum == RoleEnum.client
                ? BlocBuilder<AccountBloc, AccountState>(
                    builder: (context, state) {
                      List<User> userList =
                          context.read<AccountBloc>().clientUserList;

                      if (state is ClientAccountListLoadedState) {
                        userList = state.userList;
                      } else if (state is AccountErrorState) {
                        UiRender.showDialog(context, '', state.message);
                      } else if (state is AccountLoadingState) {
                        return UiRender.loadingCircle(context);
                      }

                      return DataTable(
                        columnSpacing: 10.width,
                        dataRowMinHeight: 30.height,
                        dataRowMaxHeight: 100.height,
                        dataTextStyle: TextStyle(
                          fontSize: 15.size,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                        columns: [
                          _dataColumn('Họ và Tên'),
                          _dataColumn('Số điện thoại'),
                          _dataColumn('Ngày đăng ký'),
                        ],
                        rows: List.generate(
                          userList.length,
                          (index) => _dataRow(userList[index]),
                        ),
                      );
                    },
                  )
                : BlocBuilder<AccountBloc, AccountState>(
                    builder: (context, state) {
                      List<User> userList =
                          context.read<AccountBloc>().shipperUserList;

                      if (state is ShipperAccountListLoadedState) {
                        userList = state.userList;
                      } else if (state is AccountErrorState) {
                        UiRender.showDialog(context, '', state.message);
                      } else if (state is AccountLoadingState) {
                        return UiRender.loadingCircle(context);
                      }

                      return DataTable(
                        columnSpacing: 10.width,
                        dataRowMinHeight: 30.height,
                        dataRowMaxHeight: 100.height,
                        dataTextStyle: TextStyle(
                          fontSize: 15.size,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                        columns: [
                          _dataColumn('Họ và Tên'),
                          _dataColumn('Số điện thoại'),
                          _dataColumn('Ngày đăng ký'),
                        ],
                        rows: List.generate(
                          userList.length,
                          (index) => _dataRow(userList[index]),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  DataColumn _dataColumn(String name) {
    return DataColumn(
      label: Expanded(
        child: Text(
          name,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 5,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: 15.size,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  DataRow _dataRow(User user) {
    return DataRow(
      onLongPress: () => _onLongPressDataRow(user),
      cells: [
        DataCell(
          Center(
            child: Text(
              user.fullName,
              softWrap: true,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              user.phoneNumber,
              softWrap: true,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              user.registerDate.date,
              softWrap: true,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _userInfo(User user) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _userInfoData(
            'Số điện thoại',
            user.phoneNumber,
          ),
          _userInfoData(
            'Họ và Tên',
            user.fullName,
          ),
          _userInfoData(
            'Giới tính',
            user.getSex(),
          ),
          _userInfoData(
            'Vai trò',
            user.getRole(),
          ),
          _userInfoData(
            'Địa chỉ',
            user.address ?? 'Không xác định',
          ),
          _userInfoData(
            'Ngày đăng kí',
            user.registerDate.dateTime,
          ),
          if (user.role == RoleEnum.shipper.name) ...[
            _userInfoData(
              'Ngày bắt đầu gói dịch vụ shipper',
              user.shipperServiceStartDate?.date ?? 'Chưa đăng ký',
            ),
            _userInfoData(
              'Ngày kết thúc gói dịch vụ shipper',
              user.shipperServiceEndDate?.date ?? 'Chưa đăng ký',
            ),
          ],
        ],
      ),
    );
  }

  Widget _userInfoData(String title, String data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.height),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextSpan(
              text: data,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onError,
              ),
            )
          ],
        ),
      ),
    );
  }
}
