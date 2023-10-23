import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';

class FirebaseDatabaseService {
  static Future<void> add(dynamic object, String path) async {
    try {
      DatabaseReference ref = firebaseDatabase.ref(path);

      await ref.set(object.toJson());

      debugPrint('Added /$path');
    } catch (e, stacktrace) {
      debugPrint(e.toString());
      debugPrint(stacktrace.toString());
    }
  }

  static Future<String> get(String path) async {
    try {
      String result = '';

      DatabaseReference databaseRef = firebaseDatabase.ref();

      DataSnapshot snapshot = await databaseRef.child(path).get();

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

  static Future<void> searchAccount(String username) async {
    DatabaseReference databaseRef = firebaseDatabase.ref();

    databaseRef
        .child('/users')
        .orderByChild('name')
        .startAt(username)
        .endAt('$username\uf8ff')
        .once()
        .then((dbEvent) {
      print(dbEvent.snapshot.value.toString());
    });
  }
}
