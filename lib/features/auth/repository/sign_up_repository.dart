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

  FutureEither<bool> sendRequest(
    String licensePlate,
    String make,
    String model,
    double capacity,
    // File driverLicenseImage,
    // File carInfoImage,
    // File dangKiemImage,
    // File carImage,
    List<Map<String, dynamic>> imageList,
  ) async {
    var uri =
        Uri.parse('$baseUrl/user/driver-register'); // Replace with your URL

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('driverAccessToken');
    print(imageList.toString());
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['Car[LicensePlate]'] = licensePlate
      ..fields['Car[Make]'] = make
      ..fields['Car[Model]'] = model
      ..fields['Capacity'] = '2';
    for (var i = 0; i < imageList.length; i++) {
      print('hehe');
      var image = imageList[i];
      var filePath = image['pic'];

      // Read the file as bytes
      var fileBytes = await File(filePath).readAsBytes();
      print(fileBytes.toString());
      var type = image['type'].toString();

      request.files.add(
        http.MultipartFile.fromBytes(
          'List[$i].pic',
          fileBytes,
          filename: 'image$i', // Provide a filename for the image
        ),
      );
      request.fields['List[$i].type'] = type;

      print(request.files[i].filename); // Print the filename for verification
      print(request.fields['List[$i].pic']);
    }

    var response = await request.send();
    print(response.statusCode);
    print('Response Body: ${await response.stream.bytesToString()}');
    if (response.statusCode == 200) {
      print('Uploaded!');
      return right(true);
    } else {
      print('Failed to upload.');
      return right(false);
    }
  }
}
