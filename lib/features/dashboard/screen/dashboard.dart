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

  @override
  void initState() {
    if (!mounted) return;
    getWallet();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (mounted) {
          final hubConnection = await ref.watch(
            hubConnectionProvider.future,
          );

          hubConnection.on(
            "NotifyDriverNewTripRequest",
            (arguments) {
              try {
                context.goNamed(
                  RouteConstants.tripRequest,
                  extra: arguments,
                );
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

        final isFcmTokenUpdated =
            await ref.watch(LoginControllerProvider.notifier).updateFcmToken();
        if (isFcmTokenUpdated) {
        } else {}
      } catch (e) {
        print(e.toString());
        rethrow;
      }
    });
    super.initState();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void getWallet() async {
    if (mounted) {
      wallet = await ref
          .read(dashBoardControllerProvider.notifier)
          .getWallet(context);

      setState(() {});
    }
  }

  void getDriverInformation() async {
    if (mounted) {
      informationModel = await ref
          .read(dashBoardControllerProvider.notifier)
          .getRatingAndDailyIncome(context);
      setState(() {});
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
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menu icon on the left
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
                // InkWell with Text "Bắt đầu" and turn on icon
                Consumer(
                  builder: (context, ref, child) {
                    final currentState = ref.watch(currentStateProvider);
                    final loginController =
                        ref.watch(LoginControllerProvider.notifier);
                    return InkWell(
                      onTap: () {
                        // Toggle the current state when the InkWell is tapped
                        ref
                            .read(currentStateProvider.notifier)
                            .setCurrentStateData(!currentState);

                        // Call the appropriate method of the LoginController
                        if (currentState) {
                          loginController.driverDeactivate();
                        } else {
                          loginController.driverActivate();
                        }
                      },
                      child: Row(
                        children: [
                          AnimatedDefaultTextStyle(
                            // Use green color when currentState is true, otherwise use white
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: currentState ? Colors.green : Colors.white,
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

                // Comment icon on the right
                IconButton(
                  icon: const Icon(
                    Icons.comment,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Handle comment button tap
                  },
                ),
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
                    'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=c3d0f188ff669f89042771a20656579073cffec5a8a69747',
                initialCameraPosition: const CameraPosition(
                  zoom: 17.5,
                  target: LatLng(10.736657, 106.672240),
                  //     LatLng(
                  //   currentLocation?.latitude ?? 0,
                  //   currentLocation?.longitude ?? 0,
                  // ),
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
                        zoom: 14.5,
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
                  if (context.mounted) {
                    await ref
                        .watch(tripControllerProvider.notifier)
                        .updateLocation(
                          context,
                          currentLocation?.latitude ?? 0.0,
                          currentLocation?.longitude ?? 0.0,
                        );
                  }

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
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${oCcy.format(wallet)} đ',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        40,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              const Text(
                                                  'Doanh thu trong ngày'),
                                              Text(
                                                  "${oCcy.format(informationModel.dailyIncome)} VNĐ"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              const Text(
                                                'Đánh giá của tôi',
                                              ),
                                              Text(
                                                '${informationModel.rating}',
                                              ),
                                            ],
                                          )
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

    // Center(
    //   child: _children[_currentIndex],
    // ),
    // bottomNavigationBar: BottomNavigationBar(
    //   selectedItemColor: Pallete.primaryColor,
    //   onTap: onTabTapped,
    //   currentIndex: _currentIndex,
    //   items: const [
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.home_filled),
    //       label: 'Home',
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.history_outlined),
    //       label: 'Activity',
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(
    //         IconData(
    //           0xf74d,
    //           fontFamily: CupertinoIcons.iconFont,
    //           fontPackage: CupertinoIcons.iconFontPackage,
    //         ),
    //       ),
    //       label: 'Account',
    //     )
    //   ],
    // ),
  }
}
