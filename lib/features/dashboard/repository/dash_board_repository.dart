import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';
import 'package:goshare_driver/models/driver_personal_information_model.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
