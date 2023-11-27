import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:location/location.dart';
import 'dart:async';

final locationProvider = Provider<LocationUtils>((ref) => LocationUtils());

class LocationUtils {
  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    // Get location data if permission is granted
    if (permissionGranted == PermissionStatus.granted) {
      print('get current location');
      //LocationData locationData = await location.getLocation();
      LocationData? locationData = await Future.any([
        location.getLocation(),
        Future.delayed(const Duration(seconds: 5), () => null),
      ]);
      locationData ??= await location.getLocation();
      return locationData;
    }

    return null;
  }

  // static FutureEither<VietmapPlaceModel> getPlaceDetail(String placeId) async {
  //   try {
  //     final queryParameters = {
  //       'apikey': Constants.vietMapApiKey,
  //       'refid': placeId
  //     };
  //     final uri = Uri.https(
  //       'maps.vietmap.vn',
  //       '/api/place/v3',
  //       queryParameters,
  //     );
  //     print(uri);
  //     var res = await http.get(uri);
  //     print(res.body);
  //     if (res.statusCode == 200) {
  //       var data = VietmapPlaceModel.fromJson(res.body);
  //       return right(data);
  //     } else {
  //       return left(
  //         Failure('Có lỗi xảy ra'),
  //       );
  //     }
  //   } on TimeoutException catch (_) {
  //     return left(
  //       Failure('Timeout'),
  //     );
  //   }
  // }
}
