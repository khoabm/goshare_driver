import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/failure.dart';
import 'package:goshare_driver/core/utils/utils.dart';

import 'package:goshare_driver/features/auth/repository/log_in_repository.dart';
import 'package:goshare_driver/providers/current_state_provider.dart';

final LoginControllerProvider = StateNotifierProvider<LoginController, bool>(
  (ref) => LoginController(
    loginRepository: ref.watch(loginRepositoryProvider),
    ref: ref,
  ),
);

class LoginController extends StateNotifier<bool> {
  final LoginRepository _loginRepository;
  final Ref _ref;
  LoginController({
    required LoginRepository loginRepository,
    required final Ref ref,
  })  : _loginRepository = loginRepository,
        _ref = ref,
        super(false);
  Future<LoginResult> login(
    String phone,
    String passcode,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final result = await _loginRepository.login(phone, passcode, ref);
    return result;
  }

  Future<bool> updateFcmToken() async {
    final result = await _loginRepository.updateFcmToken();
    result.fold(
      (l) {},
      (success) {
        state = success;
      },
    );
    return state;
  }

  Future<bool> driverActivate(BuildContext context) async {
    final result = await _loginRepository.driverActivate();
    result.fold(
      (l) {
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        state = success;
        _ref.read(currentStateProvider.notifier).setCurrentStateData(
              true,
            );
      },
    );
    return state;
  }

  Future<bool> driverDeactivate(BuildContext context) async {
    final result = await _loginRepository.driverDeactivate();
    result.fold(
      (l) {
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        state = success;
        _ref.read(currentStateProvider.notifier).setCurrentStateData(
              false,
            );
      },
    );
    return state;
  }

  Future<String> getUserData(BuildContext context, WidgetRef ref) async {
    final result = await _loginRepository.getUserData(ref);
    String data = '';
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
      print(r);
      data = r;
    });
    return data;
  }

  Future<bool> removeFcmToken(BuildContext context) async {
    bool check = false;
    final result = await _loginRepository.removeFcmToken();
    result.fold(
      (l) {
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        check = success;
      },
    );
    return check;
  }
}
