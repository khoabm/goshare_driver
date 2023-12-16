import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:image_picker/image_picker.dart';

import 'package:goshare_driver/common/app_text_field.dart';
import 'package:goshare_driver/features/auth/controllers/sign_up_controller.dart';

class DriverInformationRegister extends ConsumerStatefulWidget {
  final String passcode;

  const DriverInformationRegister({
    super.key,
    required this.passcode,
  });

  @override
  ConsumerState createState() => _DriverInformationRegisterState();
}

class _DriverInformationRegisterState
    extends ConsumerState<DriverInformationRegister> {
  int _currentStep = 0;
  final List<List<File?>> _images = [
    [null, null],
    [null, null],
    [null, null],
    //[null, null],
    [null],
    [null],
  ];
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _carModelTextController = TextEditingController();
  final TextEditingController _carMakeController = TextEditingController();
  final _driverInfoFormKey = GlobalKey<FormState>();
  int groupValue = 0;

  void checkFiles() async {
    if (_driverInfoFormKey.currentState!.validate()) {
      for (int i = 0; i < _images.length; i++) {
        for (int j = 0; j < _images[i].length; j++) {
          if (_images[i][j] == null) {
            if (i == 0) {
              showErrorRegisDialog(
                context: context,
                message: 'Vui lòng bổ sung ảnh căn cước',
              );
            } else if (i == 1) {
            } else if (i == 2) {
            } else if (i == 3) {
            } else if (i == 4) {}
            return;
          }
        }
      }
      print('All files are not null');
      List<Map<String, dynamic>> imageList = [
        {"pic": _images[0][0]?.path, "type": 0},
        {"pic": _images[0][1]?.path, "type": 0},
        {"pic": _images[1][0]?.path, "type": 1},
        {"pic": _images[1][1]?.path, "type": 1},
        {"pic": _images[2][0]?.path, "type": 2},
        {"pic": _images[2][1]?.path, "type": 2},
        {"pic": _images[3][0]?.path, "type": 3},
        {"pic": _images[4][0]?.path, "type": 4},
      ];
      final result =
          await ref.watch(signUpControllerProvider.notifier).sendRequest(
                _nameTextController.text,
                _carModelTextController.text,
                _carMakeController.text,
                groupValue,
                widget.passcode,
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
    } else {
      showErrorRegisDialog(
        context: context,
        message: 'Vui lòng điền thông tin tài xế',
      );
    }
  }

  void navigateToSuccessScreen() {
    context.goNamed(RouteConstants.driverRegisSuccess);
  }

  void showErrorRegisDialog({
    required BuildContext context,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Có lỗi xảy ra khi đăng ký thông tin'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Xác nhận'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Hình ảnh giấy tờ'),
      ),
      body: Stepper(
        controlsBuilder: (context, details) {
          return Row(
            children: <Widget>[
              if (_currentStep > 0 && _currentStep <= 5)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Quay lại'),
                ),
              if (_currentStep > 0 && _currentStep != 5)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Tiếp tục'),
                ),
              if (_currentStep == 0)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Tiếp tục'),
                ),
              if (_currentStep == 5)
                ElevatedButton(
                  onPressed: () {
                    checkFiles();
                  },
                  child: const Text('Xác nhận'),
                ),
            ],
          );
        },
        type: StepperType.horizontal,
        onStepCancel: () {
          if (_currentStep == 0) return;
          setState(() {
            _currentStep -= 1;
          });
        },
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep >= 5) return;
          setState(() {
            _currentStep += 1;
          });
        },
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: List<Step>.generate(
          6,
          (index) => Step(
            state: index == _currentStep
                ? StepState.editing
                : index < _currentStep
                    ? StepState.complete
                    : StepState.indexed,
            isActive: index == _currentStep,
            title: const Flexible(
              child: Text(''),
            ),
            content: index == 0
                ? _buildForm() // Display a form for the first step
                : Column(
                    children: [
                      Text(
                        index == 1
                            ? 'Căn cước'
                            : index == 2
                                ? 'Bằng lái xe'
                                : index == 3
                                    ? 'Giấy tờ xe'
                                    : index == 4
                                        ? 'Đăng kiểm'
                                        : index == 5
                                            ? 'Ảnh nhận diện'
                                            : '',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold), // Add this line
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (_images[index - 1].length > 1)
                        const Text('Mặt trước'),
                      _buildImagePicker(index - 1, 0),
                      const SizedBox(height: 20),
                      if (_images[index - 1].length > 1) ...[
                        const Text('Mặt sau'),
                        _buildImagePicker(index - 1, 1),
                      ],
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _driverInfoFormKey,
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
            height: 20,
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
            formatters: [
              LengthLimitingTextInputFormatter(8),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Biển số xe không được trống';
              } else if (value.length < 8) {
                return 'Biển số xe phải là 8 ký tự';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 20,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Hãng xe không được trống';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 20,
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Dòng xe không được trống';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 20,
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
            height: 100,
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: [
                buildRadioButton(2),
                buildRadioButton(4),
                buildRadioButton(7),
                buildRadioButton(9),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
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

  Widget _buildImagePicker(int stepIndex, int imageIndex) {
    // Check if the image at the given indices exists
    if (stepIndex < _images.length && imageIndex < _images[stepIndex].length) {
      return GestureDetector(
        onTap: () async {
          final pickedFile =
              await ImagePicker().pickImage(source: ImageSource.gallery);
          setState(() {
            if (pickedFile != null) {
              _images[stepIndex][imageIndex] = File(pickedFile.path);
            } else {
              print('No image selected.');
            }
          });
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          dashPattern: const [10, 4],
          strokeCap: StrokeCap.round,
          color: Colors.blue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: _images[stepIndex][imageIndex] != null
                ? Center(
                    child: Image.file(
                      _images[stepIndex][imageIndex]!,
                      fit: BoxFit.contain,
                    ),
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
      );
    } else {
      // Return an empty Container if the image does not exist
      return Container();
    }
  }
}
