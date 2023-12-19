import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goshare_driver/theme/pallet.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.black,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG image
            SvgPicture.asset(
              'assets/images/car_banner.svg', // Replace with your SVG file path
              height: 150, // Adjust the height
              width: 150, // Adjust the width
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Goshare driver',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Customize the text color
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'Hỗ trợ đón trả khách hàng',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Customize the text color
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
