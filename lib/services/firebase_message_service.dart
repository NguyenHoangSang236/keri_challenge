import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../bloc/authorization/author_bloc.dart';
import '../bloc/google_map/google_map_bloc.dart';
import '../core/router/app_router_config.dart';
import '../main.dart';
import '../util/ui_render.dart';
import 'local_storage_service.dart';

class FirebaseMessageService {
  final BuildContext context;

  FirebaseMessageService(this.context);

  Future<void> initNotifications() async {
    // request for permission to get notifications from app
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    // get FCM token for this device
    final fcmToken = await firebaseMessaging.getToken();
    debugPrint('FCM token: $fcmToken');

    // cache phone fcm token
    LocalStorageService.setLocalStorageData('phoneToken', fcmToken);

    // subscribe to a topic to get messages from that topic
    firebaseMessaging.subscribeToTopic('all');

    initPushNotifications();
    initLocalNotifications();
  }

  Future initPushNotifications() async {
    // user for IOS, config foreground message options
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // event handler when application is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      debugPrint('Title: ${message?.notification?.title}');
      debugPrint('Body: ${message?.notification?.body}');
      debugPrint('Data: ${message?.data}');
    });

    // event handler when user press on the message
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
    });

    // application gets a message when it is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // event handler when application gets a message on foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;

      if (notification != null) {
        localNotification.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              androidChannel.id,
              androidChannel.name,
              channelDescription: androidChannel.description,
              icon: '@drawable/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      }
    });
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const ios = DarwinInitializationSettings();
    const setting = InitializationSettings(android: android, iOS: ios);

    // init local notification settings for both platforms
    await localNotification.initialize(
      setting,
      // handle on press message event
      onDidReceiveNotificationResponse: (notiResponse) {
        Map<String, dynamic> jsonMap = jsonDecode(notiResponse.payload!);

        final message = RemoteMessage.fromMap(jsonMap);

        debugPrint('Pressed on push message');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
        debugPrint('Payload: ${jsonDecode(notiResponse.payload!)}');

        if (context.read<AuthorBloc>().currentUser != null) {
          if (jsonMap['notification']['title'] == 'Notice !!') {
            debugPrint('Public message');
            context.read<GoogleMapBloc>()
              ..add(OnClearLocationEvent(true))
              ..add(OnClearLocationEvent(false))
              ..add(
                OnLoadLocationFromPublicMessageEvent(
                  jsonMap['data']['startDes'] as String,
                  jsonMap['data']['endDes'] as String,
                  LatLng(
                    double.parse(jsonMap['data']['startLat']),
                    double.parse(jsonMap['data']['startLng']),
                  ),
                  LatLng(
                    double.parse(jsonMap['data']['endLat']),
                    double.parse(jsonMap['data']['endLng']),
                  ),
                  jsonMap['data']['fromPhoneToken'] as String,
                ),
              );
          } else {
            debugPrint('Private message');
            context.read<GoogleMapBloc>()
              ..add(OnClearLocationEvent(true))
              ..add(OnClearLocationEvent(false))
              ..add(OnLoadLocationFromPrivateMessageEvent(
                jsonMap['data']['senderDes'],
                LatLng(
                  double.parse(jsonMap['data']['senderLat']),
                  double.parse(jsonMap['data']['senderLng']),
                ),
              ));
          }
        } else {
          UiRender.showConfirmDialog(context, '', 'Please login first!');
          context.router.replaceAll([const LoginRoute()]);
        }
      },
    );

    final platform = localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(androidChannel);
  }

  static Future<void> sendMessage({
    Map<String, dynamic>? data,
    required String title,
    required String content,
    String? receiverToken,
  }) async {
    // if (token.isEmpty) {
    //   debugPrint('Unable to send FCM message, no token exists.');
    //   return;
    // }
    Map<String, dynamic> dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
    };

    if (data != null) {
      dataMap.addAll(data);
    }

    Map<String, dynamic> payload = {
      'data': dataMap,
      'notification': {
        'title': title,
        'body': content,
      },
    };

    payload['to'] = receiverToken != null && receiverToken.isNotEmpty
        ? receiverToken
        : '/topics/all';

    String payloadString = payload.toString();
    debugPrint(payloadString);

    try {
      await dio.post(
        'https://fcm.googleapis.com/fcm/send',
        options: Options(headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$webServerKey',
        }),
        data: payload,
      );

      debugPrint('FCM request for device sent!');
    } catch (e, stackTrace) {
      debugPrint('Caught ${e.toString()} \n${stackTrace.toString()}');
    }
  }
}
