import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/app_button.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/common/home_center_container.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/constants/login_error_constants.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/auth/controllers/log_in_controller.dart';

import 'package:goshare_driver/theme/pallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

final accessTokenProvider = StateProvider<String?>((ref) => null);
final userProvider = StateProvider<User?>((ref) => null);

class User {
  String id;
  String phone;
  String name;
  String role;

  User({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
  });
}

final tabProvider = StateProvider<int>(
  (ref) => 0,
);

class LeftSideText extends StatelessWidget {
  final String title;
  const LeftSideText({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 3.0,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Pallete.primaryColor,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class LogInScreen extends ConsumerStatefulWidget {
  const LogInScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();
  final TextEditingController _passcodeTextController = TextEditingController();

  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _phoneNumberTextController.dispose();
    _passcodeTextController.dispose();
  }

  void _onSubmit(WidgetRef ref) async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String phone = _phoneNumberTextController.text;
      String passcode = _passcodeTextController.text;

      final result = await ref.read(LoginControllerProvider.notifier).login(
            phone,
            passcode,
            ref,
            context,
          );
      setState(() {
        _isLoading = false;
      });
      if (result.error != null) {
        print('Error: ${result.error}');
        if (result.error == LoginErrorConstants.phoneNumberNotExist ||
            result.error == LoginErrorConstants.wrongPassword) {
          if (mounted) {
            showWrongPasswordDialog(context);
          }
        } else if (result.error == LoginErrorConstants.accountNotVerified) {
          if (mounted) {
            showNotVerifiedDialog(context, ref, phone);
          }
        } else {
          if (mounted) {
            showBannedDialog(context, result.error ?? 'Có lỗi xảy ra');
          }
        }
      } else {
        // Map<String, dynamic> resultMap = json.decode(result);
        // print(resultMap);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('driverAccessToken', result.accessToken!);
        prefs.setString('driverRefreshToken', result.refreshToken!);
        // if (resultMap.containsKey('id') &&
        //     resultMap.containsKey('phone') &&
        //     resultMap.containsKey('name') &&
        //     resultMap.containsKey('role')) {
        //   User userTmp = User(
        //     id: resultMap['id'],
        //     phone: resultMap['phone'],
        //     name: resultMap['name'],
        //     role: resultMap['role'],
        //   );
        ref.read(userProvider.notifier).state = result.user;
        setState(() {});
        //print(ref.read(userProvider.notifier).state?.id);
        navigateToDashBoardScreen();
      }
    }
  }

  void navigateToDashBoardScreen() {
    context.goNamed(RouteConstants.dashBoard);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                      8.0,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .3,
                    child: SvgPicture.asset(
                      Constants.carBanner,
                      fit: BoxFit.fill,
                    ),
                  ),
                  HomeCenterContainer(
                    width: MediaQuery.of(context).size.width * .9,
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const LeftSideText(
                            title: 'Số điện thoại',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          AppTextField(
                            prefixIcons: const Icon(Icons.phone),
                            controller: _phoneNumberTextController,
                            hintText: '0987654321',
                            inputType: TextInputType.phone,
                            formatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const LeftSideText(
                            title: 'Mật khẩu 6 số',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          AppTextField(
                            controller: _passcodeTextController,
                            hintText: '123456',
                            isObscure: true,
                            prefixIcons: const Icon(
                              Icons.password,
                            ),
                            inputType: TextInputType.phone,
                            formatters: [
                              LengthLimitingTextInputFormatter(6),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context.pushNamed(
                                            RouteConstants.userExistConfirm);
                                      },
                                      child: const Text('Chưa có tài khoản?'),
                                    ),
                                    // TextButton(
                                    //   onPressed: () {},
                                    //   child: const Text('Quên mật khẩu?'),
                                    // ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(
                                  8.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: AppButton(
                                    buttonText: 'Đăng nhập',
                                    onPressed: () => _onSubmit(ref),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Loader(),
              ),
          ],
        ),
      ),
    );
  }
}
