import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/auth/repository/sign_up_repository.dart';

final signUpControllerProvider = StateNotifierProvider<SignUpController, bool>(
  (ref) => SignUpController(
    signUpRepository: ref.watch(signUpRepositoryProvider),
  ),
);

class SignUpController extends StateNotifier<bool> {
  final SignUpRepository _signUpRepository;
  SignUpController({
    required SignUpRepository signUpRepository,
  })  : _signUpRepository = signUpRepository,
        super(false);

  Future<bool> registerUser(
    String name,
    String phone,
    int gender,
    DateTime birth,
    BuildContext context,
  ) async {
    final result = await _signUpRepository.registerUser(
      name,
      phone,
      gender,
      birth,
    );

    result.fold(
      (l) {
        state = false;
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        state = success;
      },
    );
    return state;
  }

  Future<String> verifyAccountExist(
    String phone,
    String passcode,
    BuildContext context,
  ) async {
    final result = await _signUpRepository.verifyAccountExist(
      phone,
      passcode,
    );
    String data = '';
    result.fold(
      (l) {
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        data = success;
      },
    );
    return data;
  }

  Future<String?> sendOtpVerification(
    String phone,
    String otp,
    BuildContext context,
  ) async {
    String? setToken;
    final result = await _signUpRepository.sendOtpVerification(
      phone,
      otp,
    );
    result.fold(
      (l) {
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        setToken = success;
      },
    );
    return setToken;
  }

  Future<bool> setPasscode(
    String phone,
    String setToken,
    String passcode,
    BuildContext context,
  ) async {
    final result = await _signUpRepository.setPasscode(
      phone,
      passcode,
      setToken,
    );
    result.fold(
      (l) {
        state = false;
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        state = success;
      },
    );
    return state;
  }

  Future<bool> sendRequest(
    String licensePlate,
    String make,
    String model,
    int capacity,
    String phone,
    List<Map<String, dynamic>> imageList,
    BuildContext context,
  ) async {
    final result = await _signUpRepository.sendRequest(
      licensePlate,
      make,
      model,
      capacity,
      imageList,
      phone,
    );
    result.fold(
      (l) {
        state = false;
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        state = success;
      },
    );
    return state;
  }

  Future<bool> reSendOtpVerification(
    String phone,
    BuildContext context,
  ) async {
    final result = await _signUpRepository.reSendOtpVerification(
      phone,
    );
    result.fold(
      (l) {
        state = false;
        showSnackBar(
          context: context,
          message: l.message,
        );
      },
      (success) {
        state = success;
      },
    );
    return state;
  }
}
