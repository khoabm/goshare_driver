import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';

void showSnackBar({
  required BuildContext context,
  required String message,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
}

void showLoginTimeOut({
  required BuildContext context,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Phiên đăng nhập hết hạn'),
        content: const Text('Vui lòng đăng nhập lại.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              context.pop();
              context.go(RouteConstants.loginUrl);
            },
          ),
        ],
      );
    },
  );
}

void showErrorDialog({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Có lỗi xảy ra'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      );
    },
  );
}

String convertPhoneNumber(String phoneNumber) {
  // Check if the phone number starts with '0'
  if (phoneNumber.startsWith('0')) {
    // Remove the leading '0' and add '84' at the beginning
    return '84${phoneNumber.substring(1)}';
  } else {
    // If the phone number doesn't start with '0', return as is
    return phoneNumber;
  }
}
