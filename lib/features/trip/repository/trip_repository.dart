import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/type_def.dart';
import 'package:goshare_driver/core/utils/http_utils.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    double? currentLat,
    double? currentLon,
    String? imagePath,
    String tripId,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      var uri = Uri.parse('$baseApiUrl/driver/confirm-pickup/$tripId');
      var request = http.MultipartRequest('POST', uri)
        ..fields['driverLatitude'] = currentLat.toString()
        ..fields['driverLongitude'] = currentLon.toString();
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
        Map<String, dynamic> tripData = json.decode(responseData);
        Trip trip = Trip.fromMap(tripData);
        return right(trip);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else if (response.statusCode == 400) {
        if (jsonDecode(responseData)['message'] ==
            'The driver is not near the pickup location. $currentLat & $currentLon') {
          return left(
            Failure('Không đủ gần điểm trả khách'),
          );
        } else {
          return left(
            Failure(jsonDecode(responseData)['message']),
          );
        }
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

  FutureEither<Trip> confirmEndTrip(
    double? currentLat,
    double? currentLon,
    String? imagePath,
    String tripId,
  ) async {
    try {
      // Map<String, dynamic> tripModelMap = tripModel.toMap();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('driverAccessToken');
      var uri = Uri.parse('$baseApiUrl/driver/end-trip/$tripId');
      var request = http.MultipartRequest('POST', uri)
        ..fields['driverLatitude'] = currentLat.toString()
        ..fields['driverLongitude'] = currentLon.toString();
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
      // final client = HttpClientWithAuth(accessToken ?? '');
      // final response = await client.post(
      //   Uri.parse('$baseApiUrl/driver/end-trip/$tripId'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //   },
      //   body: json.encode({
      //     "driverLatitude": currentLat,
      //     "driverLongitude": currentLon,
      //   }),
      // );
      // print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> tripData = json.decode(responseData);
        Trip trip = Trip.fromMap(tripData);
        return right(trip);
      } else if (response.statusCode == 429) {
        return left(Failure('Too many request'));
      } else if (response.statusCode == 401) {
        return left(UnauthorizedFailure('Unauthorized'));
      } else if (response.statusCode == 400) {
        if (jsonDecode(responseData)['message'] ==
            'The driver is not near the drop-off location.') {
          return left(
            Failure('Không đủ gần điểm trả khách'),
          );
        } else {
          return left(
            Failure(jsonDecode(responseData)['message']),
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
          print('Update thanh cong');
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
