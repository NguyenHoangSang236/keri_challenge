import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/enum/local_storage_enum.dart';
import '../main.dart';
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

    debugPrint('Finish notification initiation');
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

        // if (context.read<AuthorBloc>().currentUser != null) {
        //   if (jsonMap['notification']['title'] == 'Notice !!') {
        //     debugPrint('Public message');
        //     context.read<GoogleMapBloc>()
        //       ..add(OnClearLocationEvent(true))
        //       ..add(OnClearLocationEvent(false))
        //       ..add(
        //         OnLoadLocationFromPublicMessageEvent(
        //           jsonMap['data']['startDes'] as String,
        //           jsonMap['data']['endDes'] as String,
        //           LatLng(
        //             double.parse(jsonMap['data']['startLat']),
        //             double.parse(jsonMap['data']['startLng']),
        //           ),
        //           LatLng(
        //             double.parse(jsonMap['data']['endLat']),
        //             double.parse(jsonMap['data']['endLng']),
        //           ),
        //           jsonMap['data']['fromPhoneToken'] as String,
        //         ),
        //       );
        //   } else {
        //     debugPrint('Private message');
        //     context.read<GoogleMapBloc>()
        //       ..add(OnClearLocationEvent(true))
        //       ..add(OnClearLocationEvent(false))
        //       ..add(OnLoadLocationFromPrivateMessageEvent(
        //         jsonMap['data']['senderDes'],
        //         LatLng(
        //           double.parse(jsonMap['data']['senderLat']),
        //           double.parse(jsonMap['data']['senderLng']),
        //         ),
        //       ));
        //   }
        // } else {
        //   UiRender.showConfirmDialog(context, '', 'Please login first!');
        //   context.router.replaceAll([const LoginRoute()]);
        // }
      },
    );

    final platform = localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(androidChannel);
  }

  static Future<void> subscribeToTopic(String topic) async {
    await firebaseMessaging
        .subscribeToTopic(topic)
        .then((value) => debugPrint('Subscribed to topic: $topic'));
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await firebaseMessaging
        .unsubscribeFromTopic(topic)
        .then((value) => debugPrint('Unsubscribed from topic: $topic'));
  }

  static Future<void> sendMessage({
    Map<String, dynamic>? data,
    required String title,
    required String content,
    String? receiverToken,
    String? topic,
  }) async {
    // if (token.isEmpty) {
    //   debugPrint('Unable to send FCM message, no token exists.');
    //   return;
    // }
    Map<String, dynamic> dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      'fromPhoneToken': await LocalStorageService.getLocalStorageData(
        LocalStorageEnum.phoneToken.name,
      ) as String,
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

    if (receiverToken != null && receiverToken.isNotEmpty) {
      payload['to'] = receiverToken;
    } else if (topic != null && topic.isNotEmpty) {
      payload['to'] = '/topics/$topic';
    }

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
