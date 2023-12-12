import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final signUpRepositoryProvider = Provider(
  (ref) => SignUpRepository(
    baseUrl: Constants.apiBaseUrl,
  ),
);

class SignUpRepository {
  final String baseUrl;

  SignUpRepository({required this.baseUrl});

  ///**
  ///Register new user with given information
  ///
  /// */
  FutureEither<bool> registerUser(
    String name,
    String phone,
    int gender,
    DateTime birth,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'name': name,
          'phone': convertPhoneNumber(phone),
          'gender': 1,
          'birth': birth.toIso8601String(),
        }),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        return right(true);
      } else if (response.statusCode == 400) {
        if (jsonDecode(response.body)['message'] == 'Phone number existed') {
          return left(Failure('Số điện thoại đã tồn tại'));
        } else {
          return left(Failure('Có lỗi xảy ra'));
        }
      } else {
        return right(false);
      }
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  ///**
  ///Send otp verification code to server
  ///
  /// */
  FutureEither<String?> sendOtpVerification(
    String phone,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': convertPhoneNumber(phone),
          'otp': otp,
        }),
      );
      if (response.statusCode == 200) {
        return right(
          response.body.toString(),
        );
      } else {
        return left(
          Failure('Gửi otp thất bại'),
        );
      }
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  FutureEither<bool> setPasscode(
      String phone, String passcode, String setToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/set-passcode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': convertPhoneNumber(phone),
          'passcode': passcode,
          'setToken': setToken,
        }),
      );
      if (response.statusCode == 200) {
        return right(true);
      } else {
        return right(false);
      }
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  FutureEither<bool> reSendOtpVerification(
    String phone,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resendotp'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': convertPhoneNumber(phone),
        }),
      );
      if (response.statusCode == 200) {
        return right(
          true,
        );
      } else {
        return left(
          Failure('Gửi otp thất bại'),
        );
      }
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  FutureEither<String> verifyAccountExist(
    String phone,
    String passcode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': convertPhoneNumber(phone),
          'passcode': passcode,
        }),
      );
      if (response.statusCode == 200) {
        return right(response.body);
      } else {
        return left(
          Failure('Có lỗi xác thực'),
        );
      }
    } catch (e) {
      return left(
        Failure(
          'Lỗi hệ thống',
        ),
      );
    }
  }

  FutureEither<bool> sendRequest(
    String licensePlate,
    String make,
    String model,
    int capacity,
    List<Map<String, dynamic>> imageList,
    String phone,
  ) async {
    print(phone);
    print(make);
    print(model);
    print(capacity);
    print(imageList.length);

    var uri =
        Uri.parse('$baseUrl/auth/driver-register'); // Replace with your URL

    //final SharedPreferences prefs = await SharedPreferences.getInstance();
    //final accessToken = prefs.getString('driverAccessToken');
    var request = http.MultipartRequest('POST', uri)
      ..fields['Car[LicensePlate]'] = licensePlate
      ..fields['Car[Make]'] = make
      ..fields['Car[Model]'] = model
      ..fields['Capacity'] = capacity.toString()
      ..fields['Phone'] = convertPhoneNumber(phone);
    for (var i = 0; i < imageList.length; i++) {
      var image = imageList[i];
      var filePath = image['pic'];

      // Read the file as bytes
      var fileBytes = await File(filePath).readAsBytes();
      var type = image['type'].toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          'List[$i].pic',
          fileBytes,
          filename: 'image$i', // Provide a filename for the image
        ),
      );
      request.fields['List[$i].type'] = type;
    }

    var response = await request.send();
    print(response.statusCode);
    String responseData = await response.stream.bytesToString();
    print(responseData);
    if (response.statusCode == 200) {
      print('hehe');
      return right(true);
    } else {
      return right(false);
    }
  }
}
