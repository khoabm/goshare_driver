import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/app_button.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/features/auth/controllers/sign_up_controller.dart';

class UserExistVerifyScreen extends ConsumerStatefulWidget {
  const UserExistVerifyScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserExistVerifyScreenState();
}

class _UserExistVerifyScreenState extends ConsumerState<UserExistVerifyScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();
  final TextEditingController _passcodeTextController = TextEditingController();

  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _passcodeTextController.dispose();
    _phoneNumberTextController.dispose();
  }

  void _onSubmit(WidgetRef ref) async {
    if (_signUpFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String passcode = _passcodeTextController.text;
      String phone = _phoneNumberTextController.text;

      final result =
          await ref.read(signUpControllerProvider.notifier).verifyAccountExist(
                phone,
                passcode,
                context,
              );
      setState(() {
        _isLoading = false;
      });
      if (result.isNotEmpty) {
        navigateToDriverInfoRegisScreen(phone);
      } else {}
    }
  }

  void navigateToDriverInfoRegisScreen(String phone) {
    context.goNamed(RouteConstants.driverInfoRegis, pathParameters: {
      'phone': phone,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusNode().unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.all(
                  12.0,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                height: MediaQuery.of(context).size.height * .5,
                child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Xác nhận tài khoản GoShare',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Số điện thoại',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
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
                      const Text(
                        'Mật khẩu 6 số',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
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
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          buttonText: 'Tiếp theo',
                          onPressed: () {
                            _onSubmit(ref);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
