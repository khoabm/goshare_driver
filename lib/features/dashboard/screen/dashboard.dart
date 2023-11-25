import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/utils/locations_util.dart';
import 'package:goshare_driver/features/auth/controllers/log_in_controller.dart';
import 'package:goshare_driver/features/dashboard/drawers/user_menu_drawer.dart';
import 'package:goshare_driver/features/trip/controller/trip_controller.dart';

import 'package:goshare_driver/providers/signalr_providers.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:location/location.dart';
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
  void _onMapCreated(VietmapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  @override
  void dispose() {
    revokeHub();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        print('Da vao home');
        final hubConnection = await ref.watch(
          hubConnectionProvider.future,
        );
        hubConnection.on(
          "NotifyDriverNewTripRequest",
          (arguments) {
            print(
              arguments.toString(),
            );
            try {
              context.goNamed(
                RouteConstants.tripRequest,
                extra: arguments,
              );
            } catch (e) {
              print(
                e.toString(),
              );
            }
          },
        );
        await hubConnection.start()?.then(
              (value) => {
                print('Start thanh cong'),
              },
            );

        hubConnection.onclose((exception) {
          print(
            exception.toString(),
          );
        });
        final isFcmTokenUpdated =
            await ref.watch(LoginControllerProvider.notifier).updateFcmToken();
        if (isFcmTokenUpdated) {
          print('fcmToken updated');
        } else {
          print('fcmTokenError');
        }
      } catch (e) {
        print(e.toString());
      }
    });
    super.initState();
  }

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Pallete.primaryColor,
          automaticallyImplyLeading: false, // Hide default back button
          title: Container(
            // decoration: const BoxDecoration(
            //   borderRadius: BorderRadius.vertical(
            //     bottom: Radius.circular(30),
            //   ),
            // ),
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
                InkWell(
                  onTap: () {
                    // Handle "Bắt đầu" tap
                  },
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      boxShadow: [
                        if (status == 1)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Bắt đầu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.power_settings_new,
                          color: Colors.white,
                        ), // Change to your turn on icon
                      ],
                    ),
                  ),
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
                    'https://api.maptiler.com/maps/basic-v2/style.json?key=erfJ8OKYfrgKdU6J1SXm',
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
                        zoom: 17.5,
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
                          zoom: 17.5,
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
                                  const Text(
                                    '100.00đ',
                                    style: TextStyle(
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
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text('Day credit \$'),
                                              Text('50.000'),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                'My Rating',
                                              ),
                                              Text(
                                                '4.7',
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
