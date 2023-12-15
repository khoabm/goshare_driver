import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/trip/repository/trip_repository.dart';
import 'package:goshare_driver/models/end_trip_model.dart';
import 'package:goshare_driver/models/trip_model.dart';

final tripControllerProvider = StateNotifierProvider<TripController, bool>(
  (ref) => TripController(
    tripRepository: ref.watch(tripRepositoryProvider),
  ),
);

class TripController extends StateNotifier<bool> {
  final TripRepository _tripRepository;
  TripController({
    required tripRepository,
  })  : _tripRepository = tripRepository,
        super(false);

  Future<Trip?> confirmPickUpPassenger(
    BuildContext context,
    double? currentLat,
    double? currentLon,
    String? imagePath,
    String tripId,
  ) async {
    Trip? trip;

    final result = await _tripRepository.confirmPickUpPassenger(
      currentLat,
      currentLon,
      imagePath,
      tripId,
    );
    result.fold((l) {
      state = false;
      if (l is UnauthorizedFailure) {
        showLoginTimeOut(
          context: context,
        );
      } else {
        showErrorDialog(
          context: context,
          message: l.message,
        );
      }
    }, (r) {
      trip = r;
    });
    return trip;
  }

  Future<EndTripModel?> confirmEndTrip(
    BuildContext context,
    double? currentLat,
    double? currentLon,
    String? imagePath,
    String tripId,
  ) async {
    EndTripModel? trip;

    final result = await _tripRepository.confirmEndTrip(
      currentLat,
      currentLon,
      imagePath,
      tripId,
    );
    result.fold((l) {
      state = false;
      if (l is UnauthorizedFailure) {
        showLoginTimeOut(
          context: context,
        );
      } else {
        showErrorDialog(
          context: context,
          message: l.message,
        );
      }
    }, (r) {
      trip = r;
    });
    return trip;
  }

  Future<bool> sendChat(
      BuildContext context, String content, String receiver) async {
    bool isSent = false;
    final result = await _tripRepository.sendChat(
      content,
      receiver,
    );
    result.fold((l) {
      if (l is UnauthorizedFailure) {
        showLoginTimeOut(
          context: context,
        );
      } else {
        showErrorDialog(
          context: context,
          message: l.message,
        );
      }
    }, (r) {
      isSent = r;
    });
    return isSent;
  }

  Future<bool> updateLocation(
    BuildContext context,
    double latitude,
    double longitude,
  ) async {
    bool isUpdate = false;
    final result = await _tripRepository.updateLocation(
      latitude,
      longitude,
    );
    result.fold((l) {
      if (l is UnauthorizedFailure) {
        showLoginTimeOut(
          context: context,
        );
      } else {
        showErrorDialog(
          context: context,
          message: l.message,
        );
      }
    }, (r) {
      isUpdate = r;
    });
    return isUpdate;
  }
}
