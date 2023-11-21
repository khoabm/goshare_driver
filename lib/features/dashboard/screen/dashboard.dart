import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/constants.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/providers/current_location_provider.dart';
import 'package:goshare_driver/providers/signalr_providers.dart';
import 'package:goshare_driver/theme/pallet.dart';
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
  void _onMapCreated(VietmapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final hubConnection = ref.watch(
          hubConnectionProvider,
        );
        await hubConnection.start()?.then(
              (value) => {
                print('Start thanh cong'),
              },
            );
        hubConnection.on("NotifyDriverNewTripRequest", (arguments) {
          print(arguments.toString());
          try {
            context.pushNamed(
              RouteConstants.tripRequest,
              extra: arguments,
            );
          } catch (e) {
            print(e.toString());
          }
        });
        hubConnection.onclose((exception) {
          print(
            exception.toString(),
          );
        });
      } catch (e) {
        print(e.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(locationProvider);
    return ref.watch(locationStreamProvider).when(
          data: (location) => SafeArea(
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
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Handle menu button tap
                        },
                      ),
                      // InkWell with Text "Bắt đầu" and turn on icon
                      InkWell(
                        onTap: () {
                          // Handle "Bắt đầu" tap
                        },
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
                          'https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${Constants.vietMapApiKey}',
                      initialCameraPosition: CameraPosition(
                        zoom: 17.5,
                        target: LatLng(
                          location.latitude ?? 0,
                          location.longitude ?? 0,
                        ),
                      ),
                      onMapCreated: (VietmapController controller) {
                        setState(() {
                          _mapController = controller;
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
                          _containerHeight =
                              _containerHeight.clamp(60.0, 250.0);
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
                                          'Credit Balance',
                                          style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Text(
                                          '100.00',
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
                                  horizontal:
                                      MediaQuery.of(context).size.width * .4,
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
                ],
              ),
            ),
          ),
          error: (e, st) => const SizedBox.shrink(),
          loading: () => const Loader(),

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
        );
  }
}
