import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/main.dart';

class FirebaseStorageService {
  static void uploadFile(
    File imgFile,
    String name, {
    required void Function(TaskSnapshot) onSuccess,
  }) {
    try {
      final fileRef = firebaseStorage.ref().child(
            name,
          );

      final UploadTask upLoadTask = fileRef.putFile(imgFile);
      upLoadTask.snapshotEvents.listen(
        (taskSnapshot) {
          switch (taskSnapshot.state) {
            case TaskState.running:
              final progress = 100.0 *
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
              debugPrint("Upload is $progress% complete.");

              break;
            case TaskState.paused:
              debugPrint('Paused uploading file');
              break;
            case TaskState.success:
              debugPrint('Uploaded file successfully');
              break;
            case TaskState.canceled:
              debugPrint('Canceled uploading file');
              break;
            case TaskState.error:
              debugPrint('Caught error uploading file');
              break;
          }
        },
      );

      upLoadTask.then(
        (taskSnapshot) => onSuccess,
      );
    } on FirebaseException catch (e, stackTrace) {
      debugPrint(
        'Caught uploading file error: ${e.toString()} \n${stackTrace.toString()}',
      );
    }
  }

  static Future<String> getFileUrl(String fileName) async {
    String url = '';

    try {
      final fileRef = firebaseStorage.ref().child(fileName);

      url = await fileRef.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint('Caught getting file url error: ${e.toString()}');
      return 'Failed';
    }
  }

  static Future<String> deleteFile(String imageName) async {
    try {
      final fileRef =
          firebaseStorage.ref().child('shipperServiceBillImage/$imageName');

      await fileRef.delete();

      return 'Xóa file thành công';
    } catch (e) {
      debugPrint('Caught getting file url error: ${e.toString()}');
      return 'Lỗi khi xóa file';
    }
  }
}
