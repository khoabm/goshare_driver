import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/trip-request/repository/trip_request_repository.dart';
import 'package:goshare_driver/models/trip_model.dart';

final tripRequestControllerProvider =
    StateNotifierProvider<TripRequestController, bool>(
  (ref) => TripRequestController(
    tripRepository: ref.watch(tripRequestRepositoryProvider),
  ),
);

class TripRequestController extends StateNotifier<bool> {
  final TripRequestRepository _tripRepository;
  TripRequestController({
    required tripRepository,
  })  : _tripRepository = tripRepository,
        super(false);

  Future<Trip?> acceptTripRequest(
      BuildContext context, String tripId, bool isAccepted) async {
    print(tripId);
    Trip? trip;
    final result = await _tripRepository.acceptTripRequest(tripId, isAccepted);
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
