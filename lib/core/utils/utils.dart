import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/features/auth/controllers/sign_up_controller.dart';
import 'package:image_picker/image_picker.dart';

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

String convertBackPhoneNumber(String phoneNumber) {
  if (phoneNumber.startsWith('+84')) {
    return '0${phoneNumber.substring(3)}';
  }
  return phoneNumber;
}

void showLoginTimeOut({
  required BuildContext context,
}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Phiên đăng nhập hết hạn'),
        content: const Text('Vui lòng đăng nhập lại.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              GoRouter.of(context).goNamed(RouteConstants.login);
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
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Có lỗi xảy ra'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}

void showErrorAcceptDialog({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Có lỗi xảy ra khi xác nhận chuyến'),
        content: const SizedBox.shrink(), //Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              //context.pop();
              Navigator.of(dialogContext).pop();
              context.goNamed(RouteConstants.dashBoard);
            },
          ),
        ],
      );
    },
  );
}

void showErrorRegisDialog({
  required BuildContext context,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Text('Có lỗi xảy ra khi đăng ký thông tin'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Xác nhận'),
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
          ),
        ],
      );
    },
  );
}

void showBannedDialog(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Lỗi đăng nhập',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(message),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
            child: const Text(
              'Xác nhận',
            ),
          ),
        ],
      );
    },
  );
}

void showWrongPasswordDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'Lỗi đăng nhập',
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text('Số điện thoại hoặc mật khẩu không chính xác'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
            child: const Text(
              'Xác nhận',
            ),
          ),
        ],
      );
    },
  );
}

void showNotVerifiedDialog(BuildContext context, WidgetRef ref, String phone) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'Lỗi đăng nhập',
          ),
        ),
        content: const Center(
          child: Text(
              'Tài khoản chưa xác thực. Chọn "Xác nhận" để tiếp tục xác thực'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final result = await ref
                  .watch(signUpControllerProvider.notifier)
                  .reSendOtpVerification(
                    phone,
                    context,
                  );
              if (context.mounted) {
                Navigator.of(abcContext).pop();
                if (result == true) {
                  context.goNamed(
                    RouteConstants.otp,
                  );
                }
              }
            },
            child: const Text(
              'Xác nhận',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
            child: const Text(
              'Hủy',
            ),
          ),
        ],
      );
    },
  );
}

void showFeedBackError(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Center(
          child: Text(
            'Lỗi phản hồi',
          ),
        ),
        content: Center(
          child: Text(message),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
            child: const Text(
              'Xác nhận',
            ),
          ),
        ],
      );
    },
  );
}

void showErrorUpdateProfileDialog(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Lỗi cập nhật thông tin',
              ),
            ),
          ],
        ),
        content: Center(
          child: Text(message),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
            child: const Text(
              'Xác nhận',
            ),
          ),
        ],
      );
    },
  );
}

void showUpdateProfileSuccessDialog(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext abcContext) {
      return AlertDialog(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Cập nhật thành công',
              ),
            ),
          ],
        ),
        content: const SizedBox.shrink(),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(abcContext).pop();
            },
            child: const Text(
              'Xác nhận',
            ),
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
    return '+84${phoneNumber.substring(1)}';
  } else {
    // If the phone number doesn't start with '0', return as is
    return phoneNumber;
  }
}

Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image;
}

Future<XFile?> takeImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);
  return image;
}
