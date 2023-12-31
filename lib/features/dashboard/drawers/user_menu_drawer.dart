import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/features/auth/controllers/log_in_controller.dart';
import 'package:goshare_driver/features/auth/screens/sign_in_screen.dart';
import 'package:goshare_driver/providers/signalr_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserMenuDrawer extends ConsumerStatefulWidget {
  const UserMenuDrawer({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserMenuDrawerState();
}

class _UserMenuDrawerState extends ConsumerState<UserMenuDrawer> {
  void _onLogout(WidgetRef ref) async {
    if (mounted) {
      // final connection = await ref.read(
      //   hubConnectionProvider.future,
      // );
      if (mounted) {
        await ref
            .watch(LoginControllerProvider.notifier)
            .removeFcmToken(context);
      }
      ref.invalidate(userProvider);
      //ref.invalidate(userProvider);
      // await connection.stop().then((value) {
      //   print('DA STOP THANH CONG');
      // });
      ref.invalidate(hubConnectionProvider);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('driverAccessToken');
      await prefs.remove('driverRefreshToken');
      if (mounted) {
        context.goNamed(RouteConstants.login);
      }
    }
  }

  void navigateToStatistic() {
    context.pushNamed(RouteConstants.statistic);
  }

  void navigateToEditProfile() {
    context.pushNamed(RouteConstants.editProfile);
  }

  void navigateToTripHistory() {
    context.pushNamed(RouteConstants.tripHistory);
  }

  void navigateToMoneyTopup() {
    context.pushNamed(RouteConstants.moneyTopup);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * .6,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    title: const Text('Thông tin'),
                    leading: const Icon(
                      Icons.person_outline,
                    ),
                    onTap: () {
                      navigateToEditProfile();
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Thống kê',
                    ),
                    leading: const Icon(
                      IconData(0xebef, fontFamily: 'MaterialIcons'),
                    ),
                    onTap: () => navigateToStatistic(),
                  ),
                  ListTile(
                    title: const Text(
                      'Lịch sử',
                    ),
                    leading: const Icon(
                      IconData(0xe314, fontFamily: 'MaterialIcons'),
                    ),
                    onTap: () => navigateToTripHistory(),
                  ),
                  ListTile(
                    title: const Text(
                      'Ví của tôi',
                    ),
                    leading: const Icon(
                      IconData(0xe041, fontFamily: 'MaterialIcons'),
                    ),
                    onTap: () => navigateToMoneyTopup(),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: ListTile(
                title: const Text(
                  'Đăng xuất',
                ),
                leading: const Icon(
                  IconData(0xe3b3, fontFamily: 'MaterialIcons'),
                ),
                onTap: () => _onLogout(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
