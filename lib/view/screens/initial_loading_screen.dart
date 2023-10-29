import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/appConfig/app_config_bloc.dart';
import '../../bloc/authorization/author_bloc.dart';
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
            child: BlocListener<AuthorBloc, AuthorState>(
              listener: (context, authenState) {
                if (authenState is AuthorLoggedInState) {
                  if (authenState.user.role == 'client') {
                    context.router.pushNamed(AppRouterPath.clientIndex);
                  } else if (authenState.user.role == 'shipper') {
                  } else if (authenState.user.role == 'admin') {}
                } else if (authenState is AuthorErrorState) {
                  context.router.replaceNamed(AppRouterPath.login);
                }
              },
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
