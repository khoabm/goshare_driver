import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:goshare_driver/common/home_center_container.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';

class RegisSuccessScreen extends ConsumerStatefulWidget {
  const RegisSuccessScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RegisSuccessScreenState();
}

class _RegisSuccessScreenState extends ConsumerState<RegisSuccessScreen> {
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
  }

  void navigateToLogInScreen() {
    context.goNamed(RouteConstants.login);
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
                    child: const Text(
                      'Chúng tôi đã nhận được đăng ký của bạn và sẽ phản hồi cho bạn trong vòng 2 đến 5 ngày làm việc.Cảm ơn bạn đã tin tưởng dịch vụ ',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await Future.delayed(
                        const Duration(
                          seconds: 1,
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      navigateToLogInScreen();
                    },
                    child: const Text(
                      'Xác nhận',
                    ),
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
