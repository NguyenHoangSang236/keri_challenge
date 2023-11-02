import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';

class UiRender {
  const UiRender._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext context,
    String content,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
      ),
    );
  }

  static LinearGradient generalLinearGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xff8D8D8C), Color(0xff000000)],
    );
  }

  static Widget loadingCircle(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  static Image convertBase64ToImage(String base64) {
    Uint8List bytesImage;

    bytesImage = const Base64Decoder().convert(base64);

    return Image.memory(bytesImage);
  }

  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'OK',
    bool needCenterMessage = true,
  }) async {
    bool? result = await showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: title.isNotEmpty ? Text(title) : null,
          content: message.isNotEmpty
              ? Text(message,
                  textAlign: needCenterMessage == true
                      ? TextAlign.center
                      : TextAlign.start)
              : null,
          actions: [
            // The "Yes" button
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop(true);
              },
              isDefaultAction: true,
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
            // The "No" button
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop(false);
              },
              isDestructiveAction: true,
              child: const Text('Huỷ'),
            )
          ],
        );
      },
    );

    return result ?? false;
  }

  static Future<void> showDialog(
    BuildContext context,
    String title,
    String message, {
    TextAlign textAlign = TextAlign.center,
  }) async {
    return showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: title.isNotEmpty ? Text(title) : null,
          content: message.isNotEmpty
              ? Text(
                  message,
                  textAlign: textAlign,
                )
              : null,
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop(true);
              },
              isDefaultAction: true,
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<String> showSingleTextFieldDialog(
    BuildContext context,
    TextEditingController? controller, {
    String? title,
    String? hintText,
  }) async {
    return await showPlatformDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return PlatformAlertDialog(
          title: Text(title ?? ''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText ?? '',
                  hintStyle: TextStyle(
                    fontFamily: 'Trebuchet MS',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.size,
                    color: const Color(0xff8D8D8C),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // The "Yes" button
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop(controller?.text ?? '');
              },
              isDefaultAction: true,
              child: const Text(
                'Gửi',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
            // The "No" button
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop('');
              },
              isDestructiveAction: true,
              child: const Text('Huỷ'),
            )
          ],
        );
      },
    );
  }
}
