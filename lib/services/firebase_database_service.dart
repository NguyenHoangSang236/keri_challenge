import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';

class FirebaseDatabaseService {
  static Future<void> set(dynamic object, String objectName) async {
    try {
      DatabaseReference ref = firebaseDatabase.ref("/users/$objectName");

      await ref.set(object.toJson());

      debugPrint('Added /$objectName');
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }

  static Future<String> get(String name) async {
    try {
      String result = '';

      DatabaseReference databaseRef = firebaseDatabase.ref();

      DataSnapshot snapshot = await databaseRef.child('/users/$name').get();

      if (snapshot.exists) {
        result = snapshot.value.toString();
      } else {
        result = 'No data available';
      }

      return result;
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());

      return e.toString();
    }
  }

  static Future<void> remove(String name) async {
    try {
      DatabaseReference ref = firebaseDatabase.ref("/$name");

      await ref.remove();

      debugPrint('removed $name');
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }
}
