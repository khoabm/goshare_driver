import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/auth/screens/sign_in_screen.dart';

import 'package:goshare_driver/models/user_data_model.dart';
import 'package:goshare_driver/providers/current_on_trip_provider.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final loginRepositoryProvider = Provider(
  (ref) => LoginRepository(
    baseUrl: Constants.apiBaseUrl,
  ),
);

class LoginRepository {
  final String baseUrl;

  LoginRepository({required this.baseUrl});

  Future<String> login(
    String phone,
    String passcode,
    WidgetRef ref,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/driver/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': convertPhoneNumber(phone),
          'passcode': passcode,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final userData = UserDataModel.fromMap(jsonData);

        ref
            .watch(currentOnTripIdProvider.notifier)
            .setCurrentOnTripId(userData.currentTrip);
        return response.body;
      } else {
        return 'cannot login';
      }
    } catch (e) {
      return 'uuu';
    }
  }

  FutureEither<bool> updateFcmToken() async {
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

      // Get FCM token
      String? fcmToken = await firebaseMessaging.getToken();

      if (fcmToken == null) {
        return left(Failure('"Failed to get FCM token"'));
      }

      // Make HTTP request
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.put(
        Uri.parse('${Constants.apiBaseUrl}/user/update-fcm'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        return right(true);
      } else {
        return left(Failure('"Failed to get FCM token"'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<bool> driverActivate() async {
    try {
      // Make HTTP request
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.post(
        Uri.parse('${Constants.apiBaseUrl}/driver/activate'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{}),
      );

      if (response.statusCode == 200) {
        return right(true);
      } else {
        return left(
          Failure('Có lỗi khi bật nhận chuyến'),
        );
      }
    } catch (e) {
      return left(
        Failure('Có lỗi xảy ra'),
      );
    }
  }

  FutureEither<bool> driverDeactivate() async {
    try {
      // Make HTTP request
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.post(
        Uri.parse('${Constants.apiBaseUrl}/driver/deactivate'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{}),
      );
      if (response.statusCode == 200) {
        return right(true);
      } else {
        return left(
          Failure('Có lỗi khi tắt nhận chuyến'),
        );
      }
    } catch (e) {
      return left(
        Failure('Có lỗi xảy ra'),
      );
    }
  }

  FutureEither<String> getUserData(WidgetRef ref) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final refreshToken = prefs.getString('driverRefreshToken');
      final response = await http
          .post(
            Uri.parse('${Constants.apiBaseUrl}/auth/refresh-token'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'AccessToken': accessToken,
              'RefreshToken': refreshToken,
            }),
          )
          .timeout(
            const Duration(
              seconds: 120,
            ),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final userData = UserDataModel.fromMap(jsonData);
        if (jsonData.containsKey('id') &&
            jsonData.containsKey('phone') &&
            jsonData.containsKey('name') &&
            jsonData.containsKey('role')) {
          User userTmp = User(
            id: jsonData['id'],
            phone: jsonData['phone'],
            name: jsonData['name'],
            role: jsonData['role'],
          );
          ref.read(userProvider.notifier).state = userTmp;
        }
        ref
            .watch(currentOnTripIdProvider.notifier)
            .setCurrentOnTripId(userData.currentTrip);
        return right(jsonData['accessToken']);
      } else {
        return left(UnauthorizedFailure('Fail to renew token'));
      }
    } on TimeoutException {
      return left(Failure(''));
    } catch (e) {
      print(e.toString());
      return left(UnauthorizedFailure('Fail to renew token'));
    }
  }
}
