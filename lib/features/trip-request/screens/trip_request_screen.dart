import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/features/trip-request/controllers/trip_request_controller.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:intl/intl.dart';

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
  //int _countdown = 120; // 2 minutes in seconds
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
        width: MediaQuery.of(context).size.width * .9,
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
        trip = Trip.fromMap(tripData);
        print(trip?.toJson());
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
    final oCcy = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      body: _isLoading
          ? const Loader()
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        Center(
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage: NetworkImage(
                              trip?.booker.avatarUrl ??
                                  'https://firebasestorage.googleapis.com/v0/b/goshare-bc3c4.appspot.com/o/7b0ae9e0-013b-4213-9e33-3321fda277b3%2F7b0ae9e0-013b-4213-9e33-3321fda277b3_avatar?alt=media',
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          trip?.passenger.name ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        trip?.type == 2
                            ? const Text(
                                'Chuyến đi này yêu cầu hình ảnh để đón khách và kết thúc chuyến',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 25,
                        ),
                        trip?.type == 2
                            ? Text(
                                '${trip?.passengerPhoneNumber ?? trip?.passenger.phone}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            : Text(
                                '${trip?.passenger.phone}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          '${oCcy.format(trip?.price)}đ',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[500],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
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
                                  decoration: BoxDecoration(
                                    color: Colors.grey[350],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          '${trip?.distance.toString() ?? 1} km',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
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
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          trip?.paymentMethod == 0
                                              ? 'Ví'
                                              : 'Tiền mặt',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: [
                                    Container(
                                      // Adjust the height as needed
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 8.0,
                                      ),
                                      width: double.infinity,
                                      child: Text(
                                        (trip?.startLocation.address != null)
                                            ? 'Từ: ${trip?.startLocation.address}'
                                            : 'Địa điểm đi',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      // Adjust the height as needed
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 8.0,
                                      ),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[350],
                                      ),
                                      child: Text(
                                        trip?.endLocation.address != null
                                            ? 'Đến: ${trip?.endLocation.address}'
                                            : "Địa điểm đến",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    trip?.note != null
                                        ? 'Ghi chú: ${trip?.note}'
                                        : 'Ghi chú',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
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
                            context.goNamed(RouteConstants.dashBoard);
                          },
                          onPress: () async {
                            final result = await ref
                                .watch(tripRequestControllerProvider.notifier)
                                .acceptTripRequest(
                                  context,
                                  trip?.id ?? '',
                                  true,
                                );
                            if (result != null) {
                              if (result.id.isNotEmpty) {
                                if (mounted) {
                                  context.goNamed(
                                    RouteConstants.pickUpPassenger,
                                    extra: trip,
                                  );
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            height: 65,
                            width: MediaQuery.of(context).size.width * .9,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () async {
                                final result = await ref
                                    .watch(
                                        tripRequestControllerProvider.notifier)
                                    .acceptTripRequest(
                                      context,
                                      trip?.id ?? '',
                                      false,
                                    );
                                if (result != null) {
                                  if (result.id.isNotEmpty) {
                                    if (context.mounted) {
                                      context.goNamed(
                                        RouteConstants.dashBoard,
                                        extra: trip,
                                      );
                                    }
                                  }
                                }
                              },
                              child: const Text(
                                'Không nhận chuyến',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
