import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';

class FirebaseDatabaseService {
  static Future<Map<String, dynamic>?> getObjectMap({
    required String collection,
    required String document,
  }) async {
    final docRef = fireStore.collection(collection).doc(document);

    docRef.get().then(
      (docSnap) {
        debugPrint(docSnap.data().toString());
        return docSnap.data();
      },
      onError: (e) => print("Error getting document: $e"),
    );

    return null;
  }

  static Future<List<Map<String, dynamic>>> getObjectMapList({
    required String collection,
  }) async {
    final docRef = fireStore.collection(collection);
    List<Map<String, dynamic>> mapList = [];

    docRef.get().then(
      (querySnap) {
        for (var docSnapshot in querySnap.docs) {
          mapList.add(docSnapshot.data());
        }

        return mapList;
      },
      onError: (e) => debugPrint("Error getting document list: $e"),
    );

    return mapList;
  }

  static Future<void> addData({
    required Map<String, dynamic> data,
    required String collection,
    required String document,
    bool needMerge = false,
  }) async {
    fireStore
        .collection(collection)
        .doc(document)
        .set(data, SetOptions(merge: needMerge))
        .onError(
          (error, stackTrace) => debugPrint(
              'Error adding data: ${error.toString()}\n${stackTrace.toString()}'),
        );
  }

  static Future<void> updateData({
    required Map<String, dynamic> data,
    required String collection,
    required String document,
  }) async {
    fireStore.collection(collection).doc(document).update(data).then(
        (value) => debugPrint("Data successfully updated!"),
        onError: (e) => debugPrint("Error updating data: $e"));
  }

  static Future<void> deleteData({
    required String collection,
    required String document,
  }) async {
    fireStore.collection(collection).doc(document).delete().then(
          (doc) => debugPrint("Document deleted"),
          onError: (e) => debugPrint("Error deleting document: $e"),
        );
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
