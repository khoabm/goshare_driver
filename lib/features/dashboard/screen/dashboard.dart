import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/utils/locations_util.dart';
import 'package:goshare_driver/features/auth/controllers/log_in_controller.dart';
import 'package:goshare_driver/features/dashboard/controllers/dash_board_controller.dart';
import 'package:goshare_driver/features/dashboard/drawers/user_menu_drawer.dart';
import 'package:goshare_driver/features/trip/controller/trip_controller.dart';
import 'package:goshare_driver/models/driver_personal_information_model.dart';
import 'package:goshare_driver/providers/current_on_trip_provider.dart';
import 'package:goshare_driver/providers/current_state_provider.dart';

import 'package:goshare_driver/providers/signalr_providers.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';

class SecondScreen extends ConsumerStatefulWidget {
  const SecondScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SecondScreenState();
}

class _SecondScreenState extends ConsumerState<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}

class DashBoard extends ConsumerStatefulWidget {
  const DashBoard({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashBoardState();
}

class _DashBoardState extends ConsumerState<DashBoard> {
  double _containerHeight = 60.0;
  VietmapController? _mapController;
  List<Marker> temp = [];
  UserLocation? userLocation;
  LocationData? currentLocation;
  bool _isLoading = false;
  int status = 1;
  double wallet = 0;
  DriverPersonalInformationModel informationModel =
      DriverPersonalInformationModel(ratingNum: 0, rating: 0, dailyIncome: 0);
  // void _onMapCreated(VietmapController controller) {
  //   setState(() {
  //     _mapController = controller;
  //   });
  // }

  @override
  void dispose() {
    //revokeHub();
    _mapController?.dispose();
    super.dispose();
  }

  void revokeHub() async {
    final hubConnection = await ref.watch(
      hubConnectionProvider.future,
    );
    hubConnection.off('NotifyDriverNewTripRequest');
  }

  Future<void> checkCurrentTripStatus() async {
    if (mounted) {
      final currentOnTripId = ref.read(currentOnTripIdProvider);
      if (currentOnTripId != null && currentOnTripId.isNotEmpty) {
        final tripInfo =
            await ref.read(dashBoardControllerProvider.notifier).getTripInfo(
                  currentOnTripId,
                  context,
                );
        // Navigate to the screen based on the trip status
        if (tripInfo?.status == 1) {
          if (context.mounted) {
            context.goNamed(
              RouteConstants.pickUpPassenger,
              extra: tripInfo,
            );
          }
        }

        if (tripInfo?.status == 2) {
          // Navigate to some other screen based on the trip status
          if (context.mounted) {
            context.goNamed(
              RouteConstants.deliverPassenger,
              extra: tripInfo,
            );
          }
        }
      } else {
        if (mounted) {
          final location = ref.read(locationProvider);
          currentLocation = await location.getCurrentLocation();

          if (context.mounted) {
            await ref.watch(tripControllerProvider.notifier).updateLocation(
                  context,
                  currentLocation?.latitude ?? 0.0,
                  currentLocation?.longitude ?? 0.0,
                );
          }
        }
      }
    }
  }

  @override
  void initState() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });
      try {
        if (mounted) {
          initSignalR();
          getWallet();
          getDriverInformation();
          await checkCurrentTripStatus();
        }
        if (mounted) {
          final isFcmTokenUpdated = await ref
              .watch(LoginControllerProvider.notifier)
              .updateFcmToken();
          if (isFcmTokenUpdated) {
          } else {}
        }
      } catch (e) {
        print(e.toString());
        rethrow;
      }
    });
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  void initSignalR() async {
    final hubConnection = await ref.watch(
      hubConnectionProvider.future,
    );

    hubConnection.on(
      "NotifyDriverNewTripRequest",
      (arguments) {
        try {
          if (mounted) {
            context.goNamed(
              RouteConstants.tripRequest,
              extra: arguments,
            );
          }
        } catch (e) {
          print(
            e.toString(),
          );
          rethrow;
        }
      },
    );
    if (hubConnection.state == HubConnectionState.disconnected) {
      await hubConnection.start()?.then(
            (value) => {
              print('Start thanh cong'),
            },
          );
    }

    hubConnection.onclose((exception) {
      print(
        exception.toString(),
      );
    });
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void getWallet() async {
    if (mounted) {
      wallet = await ref
          .read(dashBoardControllerProvider.notifier)
          .getWallet(context);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void getDriverInformation() async {
    if (mounted) {
      informationModel = await ref
          .read(dashBoardControllerProvider.notifier)
          .getRatingAndDailyIncome(context);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final oCcy = NumberFormat("#,##0", "vi_VN");

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.primaryColor,
          automaticallyImplyLeading: false, // Hide default back button
          title: Container(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menu icon on the left
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Builder(builder: (context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Handle menu button tap
                            displayDrawer(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
                // InkWell with Text "Bắt đầu" and turn on icon
                Expanded(
                  flex: 5,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final currentState = ref.watch(currentStateProvider);
                      final loginController =
                          ref.watch(LoginControllerProvider.notifier);
                      return InkWell(
                        onTap: () async {
                          // Call the appropriate method of the LoginController
                          if (currentState) {
                            final check1 =
                                await loginController.driverDeactivate(context);
                            if (check1) {}
                          } else {
                            final check =
                                await loginController.driverActivate(context);
                            if (check) {
                              final location = ref.read(locationProvider);
                              currentLocation =
                                  await location.getCurrentLocation();
                              if (mounted) {
                                ref
                                    .watch(tripControllerProvider.notifier)
                                    .updateLocation(
                                      context,
                                      currentLocation?.latitude ?? 0.0,
                                      currentLocation?.longitude ?? 0.0,
                                    );
                              }
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              // Use green color when currentState is true, otherwise use white
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    currentState ? Colors.green : Colors.white,
                              ),
                              duration: const Duration(
                                  milliseconds:
                                      200), // Change to your desired duration
                              child: const Text('Bắt đầu'),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.power_settings_new,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(
                  flex: 5,
                ),
                // Comment icon on the right
                // IconButton(
                //   icon: const Icon(
                //     Icons.comment,
                //     color: Colors.white,
                //   ),
                //   onPressed: () {
                //     // Handle comment button tap
                //   },
                // ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              top: false,
              child: VietmapGL(
                //dragEnabled: false,
                compassEnabled: false,
                myLocationEnabled: true,
                //myLocationRenderMode: MyLocationRenderMode.NORMAL,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                doubleClickZoomEnabled: false,
                styleString:
                    'https://api.maptiler.com/maps/basic-v2/style.json?key=erfJ8OKYfrgKdU6J1SXm',
                initialCameraPosition: const CameraPosition(
                  zoom: 15.5,
                  target: LatLng(10.736657, 106.672240),
                ),
                onMapCreated: (VietmapController controller) {
                  setState(() {
                    _mapController = controller;
                  });
                },
                onUserLocationUpdated: (a) {
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          a.position.latitude,
                          a.position.longitude,
                        ),
                        zoom: 15.5,
                        tilt: 0,
                      ),
                    ),
                  );
                },
                onMapRenderedCallback: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final location = ref.read(locationProvider);
                  currentLocation = await location.getCurrentLocation();
                  // getWallet();
                  // getDriverInformation();

                  // if (context.mounted) {
                  //   await ref
                  //       .watch(tripControllerProvider.notifier)
                  //       .updateLocation(
                  //         context,
                  //         currentLocation?.latitude ?? 0.0,
                  //         currentLocation?.longitude ?? 0.0,
                  //       );
                  // }

                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: LatLng(currentLocation?.latitude ?? 0,
                              currentLocation?.longitude ?? 0),
                          zoom: 14.5,
                          tilt: 0),
                    ),
                  );

                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Adjust height based on the swipe direction
                  setState(() {
                    _containerHeight += details.primaryDelta!;
                    // Clamp the height between 60 and 300
                    _containerHeight = _containerHeight.clamp(60.0, 250.0);
                  });
                },
                onVerticalDragEnd: (details) {
                  // Determine whether to fully reveal or hide the container based on the gesture velocity
                  if (details.primaryVelocity! > 0) {
                    // Swipe down
                    setState(() {
                      _containerHeight = 60.0;
                    });
                  } else {
                    // Swipe up
                    setState(() {
                      _containerHeight = 250.0;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: const BoxDecoration(
                    color: Pallete.primaryColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        30,
                      ),
                    ),
                  ),
                  height: _containerHeight,
                  //color: Pallete.primaryColor,
                  child: _containerHeight == 250
                      ? Column(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    'Số dư của tài khoản',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${oCcy.format(wallet)} đ',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 40,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              informationModel.dueDate != null
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              dialogContext) {
                                                            return AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20), // Rounded corners.
                                                              ),
                                                              title: const Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .warning,
                                                                      color: Colors
                                                                          .red), // Add an icon for visual emphasis.
                                                                  SizedBox(
                                                                      width:
                                                                          10), // Add some spacing between the icon and the text.
                                                                  Text(
                                                                    'Thông báo',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red, // Red text for emphasis.
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold, // Bold text for emphasis.
                                                                      fontSize:
                                                                          20, // Larger font size.
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    'Tài khoản của bạn đang âm tiền và cần thanh toán ${DateFormat('dd/MM/yyyy').format(informationModel.dueDate!)}. \n\nNếu đã thanh toán vui lòng bỏ qua hệ thống sẽ cập nhật lại',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16, // Larger font size.
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                    'Đóng',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Pallete
                                                                          .primaryColor, // Blue text to stand out.
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold, // Bold text for emphasis.
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Icon(IconData(
                                                            0xe33c,
                                                            fontFamily:
                                                                'MaterialIcons',
                                                          )),
                                                          const SizedBox(
                                                              width:
                                                                  8.0), // You can adjust the space between the icon and text
                                                          Text(
                                                            'Hạn thanh toán tiền.',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .orange[500],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              informationModel.warnedTime !=
                                                      null
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              dialogContext) {
                                                            return AlertDialog(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20), // Rounded corners.
                                                              ),
                                                              title: const Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .warning,
                                                                      color: Colors
                                                                          .red), // Add an icon for visual emphasis.
                                                                  SizedBox(
                                                                      width:
                                                                          10), // Add some spacing between the icon and the text.
                                                                  Text(
                                                                    'Thông báo',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red, // Red text for emphasis.
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold, // Bold text for emphasis.
                                                                      fontSize:
                                                                          20, // Larger font size.
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              content:
                                                                  const Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Text(
                                                                    'Đánh giá của bạn đang quá thấp. Vui lòng liên hệ quản trị viên.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16, // Larger font size.
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: <Widget>[
                                                                TextButton(
                                                                  child:
                                                                      const Text(
                                                                    'Đóng',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Pallete
                                                                          .primaryColor, // Blue text to stand out.
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold, // Bold text for emphasis.
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          const Icon(
                                                            IconData(
                                                              0xe33c,
                                                              fontFamily:
                                                                  'MaterialIcons',
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  8.0), // You can adjust the space between the icon and text
                                                          Text(
                                                            'Đánh giá thấp.',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .orange[500],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                      'Doanh thu ngày',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Text(
                                                      "${oCcy.format(informationModel.dailyIncome)} VNĐ",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Container(
                                              //   color: Colors.black,
                                              //   width: 1,
                                              //   height: 50,
                                              // ),
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                      'Đánh giá',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Text(
                                                      informationModel.rating
                                                          .toStringAsFixed(2),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * .4,
                          ),
                          child: const Divider(
                            //height: 1,
                            color: Colors.grey,
                            thickness: 5,
                          ),
                        ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
        drawer: const UserMenuDrawer(),
      ),
    );
  }
}
