import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/app_button.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/auth/controllers/sign_up_controller.dart';
import 'package:goshare_driver/theme/pallet.dart';

class DriverInfoRegisScreen extends ConsumerStatefulWidget {
  final String phone;
  const DriverInfoRegisScreen({
    super.key,
    required this.phone,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DriverInfoRegisScreenState();
}

class _DriverInfoRegisScreenState extends ConsumerState<DriverInfoRegisScreen> {
  File? driverLicenseFile;
  File? carInfoFile;
  File? dangKiemFile;
  File? carFile;
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _carModelTextController = TextEditingController();
  final TextEditingController _carMakeController = TextEditingController();
  int groupValue = 0;
  void selectDriverLicenseImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        driverLicenseFile = File(res.path);
      });
    }
  }

  void selectCarInfoImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        carInfoFile = File(res.path);
      });
    }
  }

  void selectCarImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        carFile = File(res.path);
      });
    }
  }

  void selectDangKiemImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        dangKiemFile = File(res.path);
      });
    }
  }

  void navigateToSuccessScreen() {
    context.goNamed(RouteConstants.driverRegisSuccess);
  }

  Widget buildRadioButton(int value) {
    return ListTile(
      leading: Radio(
        value: value,
        groupValue: groupValue,
        onChanged: (int? newValue) {
          setState(() {
            groupValue = newValue!;
          });
        },
      ),
      title: Text('$value'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () => FocusNode().unfocus(),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Đăng ký thông tin tài xế',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Biển số xe',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppTextField(
                  controller: _nameTextController,
                  hintText: '62F3-XXXXX',
                ),
                const Text(
                  'Hãng xe',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppTextField(
                  controller: _carModelTextController,
                  hintText: 'Honda, Yamaha',
                ),
                const Text(
                  'Dòng xe',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppTextField(
                  controller: _carMakeController,
                  hintText: 'Dream, Sirius',
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Xe bao nhiêu chỗ',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  height: 150,
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    children: [
                      buildRadioButton(2),
                      buildRadioButton(4),
                      buildRadioButton(7),
                      buildRadioButton(9),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Ảnh bằng lái',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: selectDriverLicenseImage,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: Pallete.primaryColor,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: driverLicenseFile != null
                          ? Image.file(
                              driverLicenseFile!,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Ảnh cà vẹt xe',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: selectCarInfoImage,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: Pallete.primaryColor,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: carInfoFile != null
                          ? Image.file(
                              carInfoFile!,
                              fit: BoxFit.fill,
                            )
                          : const Center(
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Ảnh đăng kiểm xe',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: selectDangKiemImage,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: Pallete.primaryColor,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: dangKiemFile != null
                          ? Image.file(
                              dangKiemFile!,
                              fit: BoxFit.fill,
                            )
                          : const Center(
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Ảnh xe',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: selectCarImage,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: Pallete.primaryColor,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: carFile != null
                          ? Image.file(
                              carFile!,
                              fit: BoxFit.fill,
                            )
                          : const Center(
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    buttonText: 'Xác nhận',
                    onPressed: () async {
                      List<Map<String, dynamic>> imageList = [
                        {"pic": driverLicenseFile?.path, "type": 0},
                        {"pic": carInfoFile?.path, "type": 1},
                        {"pic": dangKiemFile?.path, "type": 2},
                        {"pic": carFile?.path, "type": 3},
                      ];
                      final result = await ref
                          .watch(signUpControllerProvider.notifier)
                          .sendRequest(
                            _nameTextController.text,
                            _carModelTextController.text,
                            _carMakeController.text,
                            groupValue,
                            widget.phone,
                            imageList,
                            context,
                          );
                      if (result == true) {
                        navigateToSuccessScreen();
                      } else {
                        if (mounted) {
                          showErrorRegisDialog(
                            context: context,
                            message:
                                'Vui lòng xem lại thông tin đã điền, nếu đây là lỗi vui lòng liên hệ với hệ thống',
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
