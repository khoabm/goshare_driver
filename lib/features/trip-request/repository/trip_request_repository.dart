import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';

final tripRequestRepositoryProvider = Provider(
  (ref) => TripRequestRepository(
    baseApiUrl: Constants.apiBaseUrl,
  ),
);

class TripRequestRepository {
  final String baseApiUrl;

  TripRequestRepository({
    required this.baseApiUrl,
  });

  FutureEither<Trip> acceptTripRequest(String tripId, bool isAccepted) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');

      final client = HttpClientWithAuth(accessToken ?? '');
      final res = await client.post(
        Uri.parse('$baseApiUrl/driver/confirm-passenger/$tripId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "accept": isAccepted,
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        Map<String, dynamic> tripData = json.decode(res.body);
        Trip trip = Trip.fromMap(tripData);
        return right(trip);
      } else if (res.statusCode == 429) {
        return left(
          Failure('Too many request'),
        );
      } else {
        return left(
          Failure('Co loi xay ra'),
        );
      }
    } catch (e) {
      print(e.toString());
      return left(
        Failure('Loi roi'),
      );
    }
  }
}
