import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/dashboard/repository/dash_board_repository.dart';
import 'package:goshare_driver/models/driver_personal_information_model.dart';

final dashBoardControllerProvider =
    StateNotifierProvider<DashBoardController, bool>(
  (ref) => DashBoardController(
    dashBoardRepository: ref.watch(dashBoardRepositoryProvider),
  ),
);

class DashBoardController extends StateNotifier<bool> {
  final DashBoardRepository _dashBoardRepository;
  DashBoardController({
    required dashBoardRepository,
  })  : _dashBoardRepository = dashBoardRepository,
        super(false);

  Future<double> getWallet(
    BuildContext context,
  ) async {
    double wallet = 0;

    final result = await _dashBoardRepository.getWallet();
    result.fold((l) {
      state = false;
      if (l is UnauthorizedFailure) {
        showLoginTimeOut(
          context: context,
        );
      } else {
        showSnackBar(
          context: context,
          message: l.message,
        );
      }
    }, (r) {
      wallet = r;
    });
    return wallet;
  }

  Future<DriverPersonalInformationModel> getRatingAndDailyIncome(
    BuildContext context,
  ) async {
    DriverPersonalInformationModel data = DriverPersonalInformationModel(
      ratingNum: 0,
      rating: 0,
      dailyIncome: 0,
    );
    final result = await _dashBoardRepository.getRatingAndDailyIncome();
    result.fold((l) {
      state = false;
      if (l is UnauthorizedFailure) {
        showLoginTimeOut(
          context: context,
        );
      } else {
        showSnackBar(
          context: context,
          message: l.message,
        );
      }
    }, (r) {
      data = r;
    });
    return data;
  }
}
