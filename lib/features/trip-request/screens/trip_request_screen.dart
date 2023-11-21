import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/features/trip-request/controllers/trip_request_controller.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/theme/pallet.dart';

class CountdownButton extends StatefulWidget {
  final VoidCallback onCountdownDone;
  final VoidCallback onPress;
  const CountdownButton({
    Key? key,
    required this.onCountdownDone,
    required this.onPress,
  }) : super(key: key);

  @override
  State createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  late Timer _timer;
  int _countdown = 120; // 2 minutes in seconds

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          // Countdown done
          _timer.cancel();
          widget.onCountdownDone();
        }
      });
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        height: 65,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: widget.onPress,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chấp nhận chuyến',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Text(
                formatTime(_countdown),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TripRequest extends ConsumerStatefulWidget {
  final List<dynamic>? content;
  const TripRequest(
    this.content, {
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TripRequestState();
}

class _TripRequestState extends ConsumerState<TripRequest> {
  late final Trip? trip;
  bool _isLoading = true;
  @override
  void initState() {
    if (mounted) {
      if (widget.content != null) {
        setState(() {
          _isLoading = true;
        });
        final tripData = (widget.content as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .first;
        trip = Trip.fromJson(tripData);
        setState(() {
          _isLoading = false;
        });
      } else {
        trip = null;
        setState(() {
          _isLoading = false;
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Loader()
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(
                        trip?.booker?.avatarUrl ??
                            'https://firebasestorage.googleapis.com/v0/b/goshare-bc3c4.appspot.com/o/7b0ae9e0-013b-4213-9e33-3321fda277b3%2F7b0ae9e0-013b-4213-9e33-3321fda277b3_avatar?alt=media',
                      ),
                      backgroundColor: Colors.transparent,
                      // child: Image.network(
                      //   // trip?.booker?.avatarUrl ??
                      //   'https://firebasestorage.googleapis.com/v0/b/goshare-bc3c4.appspot.com/o/7b0ae9e0-013b-4213-9e33-3321fda277b3%2F7b0ae9e0-013b-4213-9e33-3321fda277b3_avatar?alt=media',
                      //   fit: BoxFit
                      //       .cover, // Use BoxFit.cover to make the image cover the entire CircleAvatar
                      // ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'Trần Nguyễn Quang Khải',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    '4 Chỗ Economy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      //padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  trip?.distance?.toString() ?? '1km',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 1,
                                  color: Pallete.primaryColor,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                Text(
                                  trip?.paymentMethod?.toString() ?? 'Ví',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            trip?.startLocation?.address ?? 'Địa điểm đi',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                            size: 30,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 60, // Adjust the height as needed
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 8.0,
                            ),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                            ),
                            child: Text(
                              trip?.endLocation?.address ?? "Địa điểm đến",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Text(
                              trip?.note ??
                                  'Bà già rồi lên nhà đỡ bà xuống Bà già rồi lên nhà đỡ bà xuống Lorem ipsum dolor sit amet, consectetur adipiscing n leo eget tincidunt. In vehicula quam tortor',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CountdownButton(
                    onCountdownDone: () {
                      print('Countdown done. Execute your method here.');
                    },
                    onPress: () async {
                      print(trip?.id);
                      final result = await ref
                          .watch(tripControllerProvider.notifier)
                          .acceptTripRequest(
                            context,
                            trip?.id ?? '',
                          );
                      if (result.id != null) {
                        if (result.id!.isNotEmpty) {
                          if (context.mounted) {
                            context.goNamed(
                              RouteConstants.pickUpPassenger,
                              extra: trip,
                            );
                          }
                        }
                      }
                    },
                  )
                ],
              ),
            ),
    );
  }
}