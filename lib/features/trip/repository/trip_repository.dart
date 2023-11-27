import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tripRepositoryProvider = Provider(
  (ref) => TripRepository(
    baseApiUrl: Constants.apiBaseUrl,
  ),
);

class TripRepository {
  final String baseApiUrl;

  TripRepository({
    required this.baseApiUrl,
  });

  FutureEither<Trip> confirmPickUpPassenger(
      double? currentLat, double? currentLon, String tripId) async {
    try {
      // Map<String, dynamic> tripModelMap = tripModel.toMap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.post(
        Uri.parse('$baseApiUrl/driver/confirm-pickup/$tripId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "driverLatitude": currentLat,
          "driverLongitude": currentLon,
        }),
      );
      print(response.body);
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
      print(e.toString());
      return left(
        Failure('Lỗi hệ thống'),
      );
    }
  }

  FutureEither<Trip> confirmEndTrip(
      double? currentLat, double? currentLon, String tripId) async {
    try {
      // Map<String, dynamic> tripModelMap = tripModel.toMap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      final client = HttpClientWithAuth(accessToken ?? '');
      final response = await client.post(
        Uri.parse('$baseApiUrl/driver/end-trip/$tripId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "driverLatitude": currentLat,
          "driverLongitude": currentLon,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> tripData = json.decode(response.body);
        Trip trip = Trip.fromMap(tripData);
        return right(trip);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else if (response.statusCode == 400) {
        if (jsonDecode(response.body)['message'] ==
            'The driver is not near the drop-off location.') {
          return left(
            Failure('Không đủ gần điểm trả khách'),
          );
        } else {
          return left(
            Failure('Có lỗi xảy ra'),
          );
        }
      } else {
        return left(Failure('Có lỗi xảy ra'));
      }
    } catch (e) {
      print(e.toString());
      return left(
        Failure('Lỗi hệ thống'),
      );
    }
  }

  FutureEither<bool> sendChat(
    String content,
    String receiver,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final res = await client.post(
        Uri.parse('$baseApiUrl/chat/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "receiver": receiver,
          "content": content,
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        if (res.body.isNotEmpty) {
          return right(true);
        } else {
          return right(false);
        }
      } else if (res.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else if (res.statusCode == 429) {
        return left(
          Failure('Too many request'),
        );
      } else {
        return left(
          Failure('Có lỗi xảy ra'),
        );
      }
    } catch (e) {
      print(e.toString());
      return left(
        Failure('Lỗi hệ thống'),
      );
    }
  }

  FutureEither<bool> updateLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      final client = HttpClientWithAuth(accessToken ?? '');
      final res = await client.put(
        Uri.parse('$baseApiUrl/driver/update-location'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        if (res.body.isNotEmpty) {
          return right(true);
        } else {
          return right(false);
        }
      } else if (res.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else if (res.statusCode == 429) {
        return left(
          Failure('Too many request'),
        );
      } else {
        return left(
          Failure('Có lỗi xảy ra'),
        );
      }
    } catch (e) {
      print(e.toString());
      return left(
        Failure('Lỗi hệ thống'),
      );
    }
  }
}
