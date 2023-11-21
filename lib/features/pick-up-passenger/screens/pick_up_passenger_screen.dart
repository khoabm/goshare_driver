import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/utils/locations_util.dart';
import 'package:goshare_driver/features/pick-up-passenger/views/banner_instruction.dart';
import 'package:goshare_driver/models/trip_model.dart';
// import 'package:goshare_driver/providers/current_location_provider.dart';
import 'package:goshare_driver/theme/pallet.dart';
import 'package:location/location.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/helpers.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';
import 'package:vietmap_flutter_navigation/models/way_point.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/views/navigation_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

// import 'package:goshare_driver/features/pick-up-passenger/components/bottom_sheet_address_info.dart';
// import 'package:goshare_driver/features/pick-up-passenger/components/debouncer_search.dart';
// import 'package:goshare_driver/features/pick-up-passenger/components/floating_search_bar.dart';
// import 'package:goshare_driver/features/pick-up-passenger/components/instruction_image_view.dart';
// import 'package:goshare_driver/features/pick-up-passenger/components/svg.dart';

class PickUpPassenger extends ConsumerStatefulWidget {
  final Trip? trip;
  const PickUpPassenger({
    super.key,
    this.trip,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PickUpPassengerState();
}

class _PickUpPassengerState extends ConsumerState<PickUpPassenger> {
  double _containerHeight = 60.0;
  MapNavigationViewController? _controller;
  LocationData? locationData;
  late MapOptions _navigationOption;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();

  List<WayPoint> wayPoints = [
    WayPoint(
        name: "origin point", latitude: 10.6828253, longitude: 106.7489981),
    WayPoint(
        name: "destination point", latitude: 10.762528, longitude: 106.653099)
  ];
  Widget instructionImage = const SizedBox.shrink();
  String guideDirection = "";
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  bool _isRouteBuilt = false;
  bool _isRunning = false;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    if (!mounted) return;

    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.alternatives = false;
    _navigationOption.tilt = 0;

    _navigationOption.apiKey =
        'c3d0f188ff669f89042771a20656579073cffec5a8a69747';
    _navigationOption.mapStyle =
        "https://api.maptiler.com/maps/basic-v2/style.json?key=erfJ8OKYfrgKdU6J1SXm";
    _navigationOption.customLocationCenterIcon =
        await VietMapHelper.getBytesFromAsset('assets/download.jpeg');
    _vietmapNavigationPlugin.setDefaultOptions(_navigationOption);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
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
              const Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Đón khách',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                      ),
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Bắt đầu chuyến đi',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  Icon(
                    const IconData(
                      0xe1d7,
                      fontFamily: 'MaterialIcons',
                    ),
                    color: Colors.grey[400],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            NavigationView(
              mapOptions: _navigationOption,
              onNewRouteSelected: (p0) {},
              onMapCreated: (p0) {
                //print("${location.latitude} + ${location.longitude}");
                _controller = p0;
              },
              onMapMove: () => _showRecenterButton(),
              onRouteBuilt: (p0) {
                setState(() {
                  _isRouteBuilt = true;
                });
              },
              onMapRendered: () async {
                _controller?.setCenterIcon(
                    await VietMapHelper.getBytesFromAsset(
                        'assets/download.jpeg'));
                //_controller?.buildRoute(wayPoints: wayPoints);

                _isRunning = true;
                wayPoints.clear();
                wayPoints.add(
                  WayPoint(
                      name: 'origin point',
                      latitude: locationData?.latitude,
                      longitude: locationData?.longitude),
                );
                wayPoints.add(
                  WayPoint(
                      name: 'destination point',
                      latitude: 10.538360020017008,
                      longitude: 106.41532564030986),
                );
                _controller?.buildAndStartNavigation(wayPoints: wayPoints);
              },
              // onMapLongClick: (WayPoint? point) async {
              //   if (_isRunning) return;

              //   var data =
              //       await GetLocationFromLatLngUseCase(VietmapApiRepositories())
              //           .call(LocationPoint(
              //               lat: point?.latitude ?? 0,
              //               long: point?.longitude ?? 0));
              //   EasyLoading.dismiss();
              //   data.fold((l) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(content: Text('Có lỗi xảy ra')));
              //   }, (r) => _showBottomSheetInfo(r));
              // },
              // onMapClick: (WayPoint? point) async {
              //   if (_isRunning) return;
              //   if (focusNode.hasFocus) {
              //     FocusScope.of(context).requestFocus(FocusNode());
              //     return;
              //   }
              //   EasyLoading.show();
              //   var data =
              //       await GetLocationFromLatLngUseCase(VietmapApiRepositories())
              //           .call(LocationPoint(
              //               lat: point?.latitude ?? 0,
              //               long: point?.longitude ?? 0));
              //   EasyLoading.dismiss();
              //   data.fold((l) {
              //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              //         content:
              //             Text('Không tìm thấy địa điểm gần vị trí bạn chọn')));
              //   }, (r) => _showBottomSheetInfo(r));
              // },
              onRouteProgressChange: (RouteProgressEvent routeProgressEvent) {
                setState(() {
                  this.routeProgressEvent = routeProgressEvent;
                });
                _setInstructionImage(routeProgressEvent.currentModifier,
                    routeProgressEvent.currentModifierType);
              },
              onArrival: () {
                _isRunning = false;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Container(
                        height: 100,
                        color: Colors.red,
                        child: const Text('Bạn đã tới đích'))));
              },
            ),
            Positioned(
                top: MediaQuery.of(context).viewPadding.top,
                left: 0,
                child: BannerInstructionView(
                  routeProgressEvent: routeProgressEvent,
                  instructionIcon: instructionImage,
                )),
            // Positioned(
            //     bottom: 0,
            //     child: BottomActionView(
            //       recenterButton: recenterButton,
            //       controller: _controller,
            //       onOverviewCallback: _showRecenterButton,
            //       onStopNavigationCallback: _onStopNavigation,
            //       routeProgressEvent: routeProgressEvent,
            //     )),
            // _isRunning
            //     ? const SizedBox.shrink()
            //     : Positioned(
            //         top: MediaQuery.of(context).viewPadding.top + 20,
            //         child: FloatingSearchBar(
            //           focusNode: focusNode,
            //           onSearchItemClick: (p0) async {
            //             EasyLoading.show();
            //             VietmapPlaceModel? data;
            //             var res = await GetPlaceDetailUseCase(
            //                     VietmapApiRepositories())
            //                 .call(p0.refId ?? '');
            //             res.fold((l) {
            //               EasyLoading.dismiss();
            //               return;
            //             }, (r) {
            //               data = r;
            //             });
            //             wayPoints.clear();
            //             var location = await Geolocator.getCurrentPosition(
            //               desiredAccuracy: LocationAccuracy.bestForNavigation,
            //             );
            //             wayPoints.add(WayPoint(
            //                 name: 'destination',
            //                 latitude: location.latitude,
            //                 longitude: location.longitude));
            //             if (data?.lat != null) {
            //               wayPoints.add(WayPoint(
            //                   name: '',
            //                   latitude: data?.lat,
            //                   longitude: data?.lng));
            //             }
            //             await _controller?.buildRoute(wayPoints: wayPoints);
            //           },
            //         )),
            // _isRouteBuilt && !_isRunning
            //     ? Positioned(
            //         bottom: 20,
            //         left: 0,
            //         child: SizedBox(
            //           width: MediaQuery.of(context).size.width,
            //           child: Row(
            //             mainAxisSize: MainAxisSize.max,
            //             mainAxisAlignment:
            //                 MainAxisAlignment.spaceEvenly,
            //             children: [
            //               ElevatedButton(
            //                   style: ButtonStyle(
            //                       shape: MaterialStateProperty.all<
            //                               RoundedRectangleBorder>(
            //                           RoundedRectangleBorder(
            //                               borderRadius:
            //                                   BorderRadius.circular(
            //                                       18.0),
            //                               side: const BorderSide(
            //                                   color:
            //                                       Colors.blue)))),
            //                   onPressed: () {
            //                     _isRunning = true;
            //                     _controller?.startNavigation();
            //                   },
            //                   child: const Text('Bắt đầu')),
            //               ElevatedButton(
            //                   style: ButtonStyle(
            //                       shape: MaterialStateProperty.all<
            //                               RoundedRectangleBorder>(
            //                           RoundedRectangleBorder(
            //                               borderRadius:
            //                                   BorderRadius.circular(
            //                                       18.0),
            //                               side: const BorderSide(
            //                                   color:
            //                                       Colors.blue)))),
            //                   onPressed: () {
            //                     _controller?.clearRoute();
            //                     setState(() {
            //                       _isRouteBuilt = false;
            //                     });
            //                   },
            //                   child: const Text('Xoá tuyến đường')),
            //             ],
            //           ),
            //         ),
            //       )
            //     : const SizedBox.shrink(),
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
                    _containerHeight = _containerHeight.clamp(60.0, 300.0);
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
                      _containerHeight = 300.0;
                    });
                  }
                },
                child: AnimatedContainer(
                  padding: const EdgeInsets.all(12.0),
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
                  child: _containerHeight == 300
                      ? Column(
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                      '711 Đỗ Trình Thoại, ấp 3 Hướng Thọ Phú, Tân An, Long An',
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        radius: 20,
                                        child: Icon(
                                          color: Colors.white,
                                          IconData(
                                            0xf74d,
                                            fontFamily: CupertinoIcons.iconFont,
                                            fontPackage:
                                                CupertinoIcons.iconFontPackage,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              4), // Adjust the spacing as needed
                                      Text(
                                        'Thông tin',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight
                                                .w700 // Adjust the font size as needed
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.0,
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                      'Bà già rồi lên nhà đỡ bà xuống Bà già rồi lên nhà đỡ bà xuống Lorem ipsum dolor sit amet, consectetur adipiscing n leo eget tincidunt. In vehicula quam tortor',
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.black54,
                                        radius: 20,
                                        child: Icon(
                                          color: Colors.white,
                                          IconData(0xe153,
                                              fontFamily: 'MaterialIcons'),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              4), // Adjust the spacing as needed
                                      Text(
                                        'Chat',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight
                                                .w700 // Adjust the font size as needed
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 65,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () {
                                  _controller?.clearRoute();
                                  _controller?.finishNavigation();
                                },
                                child: const Text(
                                  'Đón khách',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
          ],
        ),
      ),
    ));
  }

  _showRecenterButton() {
    recenterButton = TextButton(
        onPressed: () {
          _controller?.recenter();
          setState(() {
            recenterButton = const SizedBox.shrink();
          });
        },
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                border: Border.all(color: Colors.black45, width: 1)),
            child: const Row(
              children: [
                Icon(
                  Icons.keyboard_double_arrow_up_sharp,
                  color: Colors.lightBlue,
                  size: 35,
                ),
                Text(
                  'Về giữa',
                  style: TextStyle(fontSize: 18, color: Colors.lightBlue),
                )
              ],
            )));
    setState(() {});
  }

  _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      setState(() {
        instructionImage = SvgPicture.asset(path, color: Colors.white);
      });
    }
  }

  _onStopNavigation() {
    setState(() {
      routeProgressEvent = null;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _controller?.onDispose();
    super.dispose();
  }
}