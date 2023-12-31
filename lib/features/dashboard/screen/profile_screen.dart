import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/common/app_button.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/core/date_time_formatters.dart';
import 'package:goshare_driver/core/input_formatters.dart';
import 'package:goshare_driver/core/input_validator.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/auth/screens/sign_in_screen.dart';
import 'package:goshare_driver/features/dashboard/controllers/dash_board_controller.dart';
import 'package:goshare_driver/models/user_profile_model.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:intl/intl.dart';

enum Gender { male, female }

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  UserProfileModel? profile;
  File? avatar;
  final _profileFormKey = GlobalKey<FormState>();
  Gender? _gender;
  final TextEditingController _nameTextController = TextEditingController();
  // final TextEditingController _phoneNumberTextController =
  //     TextEditingController();
  final TextEditingController _birthDateTextController =
      TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getUserData();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextController.dispose();

    // _phoneNumberTextController.dispose();
    _birthDateTextController.dispose();
  }

  void getUserData() async {
    profile =
        await ref.watch(dashBoardControllerProvider.notifier).getUserProfile(
              context,
            );
    if (profile != null) {
      _nameTextController.text = profile!.name;
      //_phoneNumberTextController.text = convertBackPhoneNumber(profile!.phone);
      _birthDateTextController.text = DateFormat('dd/MM/yyyy').format(
        profile!.birth,
      );
      _gender = profile?.gender == 1 ? Gender.male : Gender.female;
    }
    setState(() {});
  }

  void _onSubmit(WidgetRef ref) async {
    if (_profileFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final data =
          await ref.watch(dashBoardControllerProvider.notifier).editUserProfile(
                context,
                _nameTextController.text,
                null,
                _gender!.index,
                DateTimeFormatters.convertStringToDate(
                    _birthDateTextController.text),
              );
      if (data != null) {
        if (mounted) {
          showUpdateProfileSuccessDialog(context);
          setState(() {
            profile = data;
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          // title: const Text('Edit Profile'),
          elevation: 0,
        ),
        body: profile != null
            ? Stack(
                children: [
                  SingleChildScrollView(
                    child: IgnorePointer(
                      child: Form(
                        key: _profileFormKey,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              const Text(
                                'Thông tin người dùng',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                              Center(
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Pallete
                                              .primaryColor, // Border color
                                          width: 3.0, // Border width
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: avatar != null
                                            ? FileImage(avatar!)
                                                as ImageProvider
                                            : NetworkImage(
                                                profile!.avatarUrl ??
                                                    'https://firebasestorage.googleapis.com/v0/b/goshare-bc3c4.appspot.com/o/7b0ae9e0-013b-4213-9e33-3321fda277b3%2F7b0ae9e0-013b-4213-9e33-3321fda277b3_avatar?alt=media',
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const LeftSideText(
                                title: 'Họ và tên',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              AppTextField(
                                prefixIcons: const Icon(Icons.abc),
                                controller: _nameTextController,
                                hintText: 'Nhập tên của bạn',
                                validator: (value) =>
                                    InputValidator.nullValidate(
                                  value,
                                  'Tên không được trống',
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const LeftSideText(
                                title: 'Ngày sinh',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              AppTextField(
                                hintText: 'dd/MM/yyyy',
                                prefixIcons: const Icon(Icons.calendar_today),
                                inputType: TextInputType.phone,
                                controller: _birthDateTextController,
                                formatters: [
                                  DateTextFormatter(),
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter
                                      .singleLineFormatter,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ngày sinh không được trống';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const LeftSideText(
                                title: 'Giới tính',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  const Text('Nam'),
                                  Radio<Gender>(
                                    activeColor: Pallete.primaryColor,
                                    value: Gender.male,
                                    groupValue: _gender,
                                    onChanged: (Gender? value) {
                                      setState(() {
                                        _gender = value;
                                      });
                                    },
                                  ),
                                  const Text('Nữ'),
                                  Radio<Gender>(
                                    activeColor: Pallete.primaryColor,
                                    value: Gender.female,
                                    groupValue: _gender,
                                    onChanged: (Gender? value) {
                                      setState(() {
                                        _gender = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              // Container(
                              //   padding: const EdgeInsets.all(
                              //     8.0,
                              //   ),
                              //   width: MediaQuery.of(context).size.width * .9,
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //       vertical: 16,
                              //     ),
                              //     child: AppButton(
                              //       buttonText: 'Cập nhật',
                              //       onPressed: () => _onSubmit(ref),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
