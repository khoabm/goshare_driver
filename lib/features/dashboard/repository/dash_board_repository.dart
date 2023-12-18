import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';
import 'package:goshare_driver/models/driver_personal_information_model.dart';
import 'package:goshare_driver/models/statistic_model.dart';
import 'package:goshare_driver/models/transaction_model.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final dashBoardRepositoryProvider = Provider(
  (ref) => DashBoardRepository(
    baseApiUrl: Constants.apiBaseUrl,
  ),
);

class DashBoardRepository {
  final String baseApiUrl;

  DashBoardRepository({
    required this.baseApiUrl,
  });

  FutureEither<double> getWallet() async {
    try {
      // Map<String, dynamic> tripModelMap = tripModel.toMap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.get(
        Uri.parse('$baseApiUrl/wallet'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        return right(
          double.parse(response.body),
        );
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Có lỗi xảy ra'));
      }
    } catch (e) {
      return left(
        Failure('Lỗi hệ thống'),
      );
    }
  }

  FutureEither<DriverPersonalInformationModel> getRatingAndDailyIncome() async {
    try {
      // Map<String, dynamic> tripModelMap = tripModel.toMap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      print(accessToken);
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.get(
        Uri.parse('$baseApiUrl/driver'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('ĐÂY LÀ CÁI DRIVER INFO');
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final data = DriverPersonalInformationModel.fromJson(response.body);
        return right(data);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Có lỗi xảy ra'));
      }
    } catch (e) {
      return left(
        Failure('Lỗi hệ thống'),
      );
    }
  }

  FutureEither<Trip> getTripInfo(
    String tripId,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.get(
        Uri.parse('$baseApiUrl/trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> tripData = json.decode(response.body);
        Trip trip = Trip.fromMap(tripData);

        return right(trip);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Co loi xay ra'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<WalletTransactionModel> getWalletTransaction(
    //String sortBy,
    int page,
    int pageSize,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.get(
        Uri.parse(
            '$baseApiUrl/wallettransaction?page=$page&pageSize=$pageSize'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> walletTransactionData = json.decode(response.body);
        print(walletTransactionData.toString());
        WalletTransactionModel walletTransaction =
            WalletTransactionModel.fromMap(walletTransactionData);

        return right(walletTransaction);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Co loi xay ra'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<StatisticModel>> getStatistic() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.get(
        Uri.parse('$baseApiUrl/driver/statistic'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<StatisticModel> statistics =
            jsonResponse.map((item) => StatisticModel.fromMap(item)).toList();
        return right(statistics);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Co loi xay ra'));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserProfileModel> getUserProfile() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      final client = HttpClientWithAuth(accessToken ?? '');
      final res = await client.get(
        Uri.parse('$baseApiUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> userProfileData = json.decode(res.body);
        UserProfileModel userProfile =
            UserProfileModel.fromMap(userProfileData);
        return right(userProfile);
      } else if (res.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (res.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Co loi xay ra'));
      }
    } on TimeoutException catch (_) {
      return left(
        Failure('Timeout'),
      );
    }
  }

  FutureEither<UserProfileModel> editUserProfile(
    String name,
    String? imagePath,
    int gender,
    DateTime birth,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      // final client = HttpClientWithAuth(accessToken ?? '');
      // final res = await client.put(
      //   Uri.parse('$baseApiUrl/user/profile'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      // );
      var uri = Uri.parse('$baseApiUrl/user/profile');
      var request = http.MultipartRequest('PUT', uri)
        ..fields['name'] = name
        ..fields['gender'] = gender.toString()
        ..fields['birth'] = birth.toIso8601String();
      if (imagePath != null) {
        // Read the file as bytes
        var fileBytes = await File(imagePath).readAsBytes();

        // Add the image file to the multipart request
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            fileBytes,
            filename: 'image', // Provide a filename for the image
          ),
        );
      }
      request.headers.addAll(<String, String>{
        'Authorization': 'Bearer $accessToken',
      });
      var response = await request.send();
      String responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Map<String, dynamic> userProfileData = json.decode(responseData);
        UserProfileModel userProfile =
            UserProfileModel.fromMap(userProfileData);
        return right(userProfile);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else {
        return left(Failure('Co loi xay ra'));
      }
    } on TimeoutException catch (_) {
      return left(
        Failure('Timeout'),
      );
    }
  }

  Future<Either<Failure, List<Trip>>> getTripHistory() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');

      final res = await client.get(
        Uri.parse('$baseApiUrl/trip/history'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final dynamic responseData = jsonDecode(res.body);
        print(responseData.toString());
        if (responseData.isEmpty || responseData is! List) {
          throw Exception('Unexpected response format');
        }

        final List<dynamic> data = responseData;

        final List<Trip> trips = List<Map<String, dynamic>>.from(data)
            .map((tripData) => Trip.fromMap(tripData))
            .toList();

        return right(trips);
      } else {
        final responseData = jsonDecode(res.body);
        //throw Exception('Failed to load trip history');
        return left(
          Failure(responseData['message']),
        );
      }
    } catch (error) {
      throw Exception('Failed to load trip history: $error');
    }
  }
}
