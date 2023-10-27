import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/account/account_bloc.dart';
import 'package:keri_challenge/bloc/appConfig/app_config_bloc.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/bloc/order/order_bloc.dart';
import 'package:keri_challenge/core/theme/app_theme.dart';
import 'package:keri_challenge/data/repository/account_repository.dart';
import 'package:keri_challenge/data/repository/app_config_repository.dart';
import 'package:keri_challenge/data/repository/order_repository.dart';
import 'package:keri_challenge/services/firebase_database_service.dart';

import 'config/http_client_config.dart';
import 'core/router/app_router_config.dart';
import 'data/enum/firestore_enum.dart';
import 'data/repository/google_map_repository.dart';
import 'firebase_options.dart';

const emulatorPort = 9000;
const apiKey = 'AIzaSyAORtYhclWmVTCjaK9-rDJmNx0A4U7O7qY';
const webServerKey =
    'AAAAgJn449g:APA91bFLRKFBa3_sud6wOFb3-D4LVOah-A_WqpTa6m88ix_TMhiTsEM4v6Ek4n_b-4WpEefD00Q3S2z7_jUYpblMkF2abMX_DSN2xKpdjPbf4zkAVnZD6cdwMXKrLBML_D9RASHz7FVN';
final Dio dio = Dio();

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore fireStore = FirebaseFirestore.instance;
final emulatorHost =
    (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        ? '10.0.2.2'
        : 'localhost';
final appRouter = AppRouter();

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;

const androidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notification',
  description: 'This channel is for important notifications',
  importance: Importance.max,
);

final localNotification = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  HttpOverrides.global = HttpClientConfig();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseDatabase.instance.useDatabaseEmulator(emulatorHost, emulatorPort);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GoogleMapRepository>(
          create: (context) => GoogleMapRepository(),
        ),
        RepositoryProvider<OrderRepository>(
          create: (context) => OrderRepository(),
        ),
        RepositoryProvider<AccountRepository>(
          create: (context) => AccountRepository(),
        ),
        RepositoryProvider<AppConfigRepository>(
          create: (context) => AppConfigRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<GoogleMapBloc>(
            create: (context) => GoogleMapBloc(
              RepositoryProvider.of<GoogleMapRepository>(context),
            ),
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(
              RepositoryProvider.of<OrderRepository>(context),
            ),
          ),
          BlocProvider<AuthorBloc>(
            create: (context) => AuthorBloc(
              RepositoryProvider.of<AccountRepository>(context),
            ),
          ),
          BlocProvider<AppConfigBloc>(
            create: (context) => AppConfigBloc(
              RepositoryProvider.of<AppConfigRepository>(context),
            ),
          ),
          BlocProvider<AccountBloc>(
            create: (context) => AccountBloc(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('The app is ${state.name}');

    if (state == AppLifecycleState.paused &&
        context.read<AuthorBloc>().currentUser != null) {
      await FirebaseDatabaseService.updateData(
        data: {
          'isOnline': false,
        },
        collection: FireStoreCollectionEnum.users.name,
        document: context.read<AuthorBloc>().currentUser!.phoneNumber,
      );
    } else if (state == AppLifecycleState.resumed &&
        context.read<AuthorBloc>().currentUser != null) {
      await FirebaseDatabaseService.updateData(
        data: {
          'isOnline': true,
        },
        collection: FireStoreCollectionEnum.users.name,
        document: context.read<AuthorBloc>().currentUser!.phoneNumber,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: appRouter.config(),
          debugShowCheckedModeBanner: false,
          theme: appTheme,
        );
      },
    );
  }
}
