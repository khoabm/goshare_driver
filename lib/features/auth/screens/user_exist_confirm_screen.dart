import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:goshare_driver/common/home_center_container.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';

class UserExistConfirmScreen extends ConsumerStatefulWidget {
  const UserExistConfirmScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserExistConfirmScreenState();
}

class _UserExistConfirmScreenState
    extends ConsumerState<UserExistConfirmScreen> {
  bool _isLoading = false;
  @override
  void dispose() {
    super.dispose();
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
        appBar: AppBar(),
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
                    child: Column(
                      children: [
                        const Text(
                          'Bạn đã tài khoản người dùng với GoShare chưa ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
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
                          },
                          child: const Text(
                            'Đã có tài khoản',
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                          ),
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
                            if (context.mounted) {
                              context.pushNamed(
                                RouteConstants.userInfoRegis,
                              );
                            }
                          },
                          child: const Text(
                            'Chưa có tài khoản',
                          ),
                        ),
                      ],
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
