import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/app_button.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/date_time_formatters.dart';
import 'package:goshare_driver/core/input_formatters.dart';
import 'package:goshare_driver/features/auth/controllers/sign_up_controller.dart';
import 'package:goshare_driver/theme/pallet.dart';

class UserInfoRegisScreen extends ConsumerStatefulWidget {
  const UserInfoRegisScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserInfoRegisScreenState();
}

class _UserInfoRegisScreenState extends ConsumerState<UserInfoRegisScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();
  final TextEditingController _birthDateTextController =
      TextEditingController();
  String? _gender;
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
    _nameTextController.dispose();
    _phoneNumberTextController.dispose();
    _birthDateTextController.dispose();
  }

  void _onSubmit(WidgetRef ref) async {
    if (_signUpFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String name = _nameTextController.text;
      String phone = _phoneNumberTextController.text;
      DateTime birth =
          DateTimeFormatters.convertStringToDate(_birthDateTextController.text);
      int gender = _gender == 'Name' ? 1 : 2;

      final result =
          await ref.read(signUpControllerProvider.notifier).registerUser(
                name,
                phone,
                gender,
                birth,
                context,
              );
      setState(() {
        _isLoading = false;
      });
      if (result) {
        navigateToOtpScreen(phone);
      } else {}
    }
  }

  void navigateToOtpScreen(String phone) {
    context.goNamed(RouteConstants.otp, pathParameters: {
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
                          'Đăng ký thông tin người dùng',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text(
                        'Họ và tên',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppTextField(
                        controller: _nameTextController,
                        hintText: 'Họ và tên',
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
                        'Ngày tháng năm sinh',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppTextField(
                        hintText: 'dd/MM/yyyy',
                        inputType: TextInputType.phone,
                        controller: _birthDateTextController,
                        formatters: [
                          DateTextFormatter(),
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.singleLineFormatter,
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text('Nam'),
                              selectedColor: Pallete.primaryColor,
                              leading: Radio<String>(
                                value: 'Nam',
                                groupValue: _gender,
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Nữ'),
                              selectedColor: Pallete.primaryColor,
                              leading: Radio<String>(
                                value: 'Nữ',
                                groupValue: _gender,
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),
                            ),
                          ),
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
