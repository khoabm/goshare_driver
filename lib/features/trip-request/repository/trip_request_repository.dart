import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:http/http.dart' as http;

final tripRepositoryProvider = Provider(
  (ref) => TripRequestRepository(
    baseApiUrl: Constants.apiBaseUrl,
  ),
);

class TripRequestRepository {
  final String baseApiUrl;

  TripRequestRepository({
    required this.baseApiUrl,
  });

  FutureEither<Trip> acceptTripRequest(String tripId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseApiUrl/trip/confirm-passenger/$tripId'),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6IkpXVCJ9.eyJpZCI6IjdiMGFlOWUwLTAxM2ItNDIxMy05ZTMzLTMzMjFmZGEyNzdiMyIsInBob25lIjoiODQ5MTk2NTEzNjEiLCJuYW1lIjoiS2jhuqNpIFRy4bqnbiIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IkRyaXZlciIsImV4cCI6MTcwMDMyMTE4MCwiaXNzIjoiand0IiwiYXVkIjoiand0In0.2mE4VBc0ii5CQoJq4CY4z35aQjaOFmn4zNR6vKFFLF8',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"accept": true}),
      );
      print(res.body);
      if (res.statusCode == 200) {
        Map<String, dynamic> tripData = json.decode(res.body);
        Trip trip = Trip.fromJson(tripData);
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
