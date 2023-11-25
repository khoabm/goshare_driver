import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserMenuDrawer extends ConsumerWidget {
  const UserMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: MediaQuery.of(context).size.width * .6,
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('Thông tin'),
              leading: const Icon(
                Icons.person_outline,
              ),
              onTap: () {},
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
