import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/dashboard/repository/dash_board_repository.dart';
import 'package:goshare_driver/models/driver_personal_information_model.dart';
import 'package:goshare_driver/models/statistic_model.dart';
import 'package:goshare_driver/models/transaction_model.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/models/user_profile_model.dart';

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

  Future<Trip?> getTripInfo(
    String tripId,
    BuildContext context,
  ) async {
    Trip? trip;
    final result = await _dashBoardRepository.getTripInfo(tripId);
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
      trip = r;
    });
    return trip;
  }

  Future<WalletTransactionModel?> getWalletTransaction(
    //String sortBy,
    int page,
    int pageSize,
    BuildContext context,
  ) async {
    WalletTransactionModel? trip;
    final result = await _dashBoardRepository.getWalletTransaction(
      //sortBy,
      page,
      pageSize,
    );
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
      trip = r;
    });
    return trip;
  }

  Future<List<StatisticModel>> getStatistic(
    BuildContext context,
  ) async {
    List<StatisticModel> list = [];
    final result = await _dashBoardRepository.getStatistic();
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
      list = r;
    });
    return list;
  }

  Future<UserProfileModel?> editUserProfile(
    BuildContext context,
    String name,
    String? imagePath,
    int gender,
    DateTime birth,
  ) async {
    UserProfileModel? profile;

    final result = await _dashBoardRepository.editUserProfile(
      name,
      imagePath,
      gender,
      birth,
    );
    result.fold((l) {
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
      // print(r.length.toString());
      profile = r;
    });
    return profile;
  }

  Future<UserProfileModel?> getUserProfile(BuildContext context) async {
    UserProfileModel? profile;

    final result = await _dashBoardRepository.getUserProfile();
    result.fold((l) {
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
      // print(r.length.toString());
      profile = r;
    });
    return profile;
  }
}
