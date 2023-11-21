import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/trip-request/repository/trip_request_repository.dart';
import 'package:goshare_driver/models/trip_model.dart';

final tripControllerProvider = StateNotifierProvider<TripController, bool>(
  (ref) => TripController(
    tripRepository: ref.watch(tripRepositoryProvider),
  ),
);

class TripController extends StateNotifier<bool> {
  final TripRequestRepository _tripRepository;
  TripController({
    required tripRepository,
  })  : _tripRepository = tripRepository,
        super(false);

  Future<Trip> acceptTripRequest(BuildContext context, String tripId) async {
    Trip trip = Trip();
    final result = await _tripRepository.acceptTripRequest(tripId);
    result.fold((l) {
      state = false;
      showSnackBar(
        context: context,
        message: l.message,
      );
    }, (r) {
      trip = r;
    });
    return trip;
  }
}
