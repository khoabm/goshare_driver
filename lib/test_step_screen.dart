import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:goshare_driver/common/app_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentStep = 0;
  final List<List<File?>> _images = [
    [null, null],
    [null, null],
    [null, null],
    [null, null],
    [null],
  ];
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _carModelTextController = TextEditingController();
  final TextEditingController _carMakeController = TextEditingController();
  int groupValue = 0;

  void checkFiles() {
    for (int i = 0; i < _images.length; i++) {
      for (int j = 0; j < _images[i].length; j++) {
        if (_images[i][j] == null) {
          print('File at index $i, $j is still null');
          // Handle the null file here
          return;
        }
      }
    }
    print('All files are not null');
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
              if (_currentStep > 0 && _currentStep <= 4)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Quay lại'),
                ),
              if (_currentStep > 0 && _currentStep != 4)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Tiếp tục'),
                ),
              if (_currentStep == 0)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Tiếp tục'),
                ),
              if (_currentStep == 4)
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
          if (_currentStep >= 4) return;
          setState(() {
            _currentStep += 1;
          });
        },
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: List<Step>.generate(
          5,
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
                      _buildImagePicker(index, 0),
                      const SizedBox(height: 10),
                      if (index < 4)
                        _buildImagePicker(index,
                            1), // Only add a second image picker for the first 4 steps
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
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
