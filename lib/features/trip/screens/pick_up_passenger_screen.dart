import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/common/loader.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/enums/trip_type_enum.dart';

import 'package:goshare_driver/core/utils/locations_util.dart';
import 'package:goshare_driver/core/utils/utils.dart';
import 'package:goshare_driver/features/trip/controller/trip_controller.dart';
import 'package:goshare_driver/features/trip/screens/chat_screen.dart';
import 'package:goshare_driver/features/trip/screens/passenger_information_screen.dart';
import 'package:goshare_driver/features/trip/views/banner_instruction.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/providers/is_chat_on_provider.dart';
import 'package:goshare_driver/providers/signalr_providers.dart';
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
    // WayPoint(
    //     name: "origin point", latitude: 10.6828253, longitude: 106.7489981),
    // WayPoint(
    //     name: "destination point", latitude: 10.762528, longitude: 106.653099)
  ];
  Widget instructionImage = const SizedBox.shrink();
  String guideDirection = "";
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  bool _isRouteBuilt = false;
  bool _isRunning = false;
  bool _isLoading = false;
  final Location location = Location();

  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;
  late final Trip? trip;
  File? pickupPictureFile;
  // bool _isChatOn = false;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initialize();
    });
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
    final location = ref.read(locationProvider);
    locationData = await location.getCurrentLocation();
    // wayPoints.clear();
    // wayPoints.add(
    //   WayPoint(
    //     name: 'origin point',
    //     latitude: locationData?.latitude ?? 10.882105930222338,
    //     longitude: locationData?.longitude ?? 106.78253348225114,
    //   ),
    // );
    // wayPoints.add(
    //   WayPoint(
    //     name: 'destination point',
    //     latitude: widget.trip?.startLocation.latitude,
    //     longitude: widget.trip?.startLocation.longitude,
    //   ),
    // );
    await _listenLocation();

    setState(() {});
  }

  void navigateToPassengerInformation() {
    context.pushNamed(
      RouteConstants.passengerInformation,
      extra: widget.trip,
    );
  }

  void navigateToDeliverPassenger() {
    context.goNamed(
      RouteConstants.deliverPassenger,
      extra: widget.trip,
    );
  }

  void navigateToChat(String receiver) {
    if (receiver.isNotEmpty) {
      context.replaceNamed(
        RouteConstants.chat,
        pathParameters: {
          'receiver': receiver,
        },
      );
    }
  }

  Future<void> _listenLocation() async {
    final hubConnection = await ref.read(
      hubConnectionProvider.future,
    );
    location.changeSettings(
      accuracy: LocationAccuracy.high,
    );
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        setState(() {
          _error = err.code;
        });
      }
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((currentLocation) {
      setState(() {
        _error = null;
        print('${currentLocation.latitude} + ${currentLocation.longitude},');
        if (mounted) {
          hubConnection.invoke(
            "SendDriverLocation",
            args: [
              jsonEncode({
                'latitude': currentLocation.latitude,
                'longitude': currentLocation.longitude
              }),
              widget.trip?.id,
            ],
          ).then((value) {
            print(
                "Location sent to server: ${currentLocation.latitude} + ${currentLocation.longitude}");
          }).catchError((error) {
            print("Error sending location to server: $error");
          });
        }
      });
    });
  }

  Future<void> takePictureToPickup() async {
    final res = await takeImage();
    if (res != null) {
      setState(() {
        pickupPictureFile = File(res.path);
      });
    }
  }

  @override
  void dispose() {
    //revokeHub();
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
    _controller?.onDispose();
    super.dispose();
  }

  void revokeHub() async {
    final hubConnection = await ref.read(
      hubConnectionProvider.future,
    );
    hubConnection.off('SendDriverLocation');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ref.watch(isChatOnProvider)
          ? ChatScreen(
              receiver: widget.trip?.bookerId ?? '',
              bookerAvatar: widget.trip?.booker.avatarUrl,
            )
          : ref.watch(isPassengerInformationOnProvider)
              ? PassengerInformationScreen(
                  trip: widget.trip,
                )
              : Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Pallete.primaryColor,
                    automaticallyImplyLeading:
                        false, // Hide default back button
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
                    child: locationData == null
                        ? const Loader()
                        : Stack(
                            children: [
                              NavigationView(
                                mapOptions: _navigationOption,
                                onNewRouteSelected: (p0) {},
                                onMapCreated: (p0) {
                                  //print("${location.latitude} + ${location.longitude}");
                                  setState(() {
                                    _controller = p0;
                                  });
                                },
                                onMapMove: () => _showRecenterButton(),
                                // onRouteBuilt: (p0) {
                                //   setState(() {
                                //     _isRouteBuilt = true;
                                //   });
                                // },
                                onMapRendered: () async {
                                  // wayPoints.clear();
                                  wayPoints.add(
                                    WayPoint(
                                      name: 'origin point',
                                      latitude: locationData?.latitude ??
                                          10.882105930222338,
                                      longitude: locationData?.longitude ??
                                          106.78253348225114,
                                    ),
                                  );
                                  wayPoints.add(
                                    WayPoint(
                                      name: 'destination point',
                                      latitude:
                                          widget.trip?.startLocation.latitude,
                                      longitude:
                                          widget.trip?.startLocation.longitude,
                                    ),
                                  );
                                  _controller?.setCenterIcon(
                                    await VietMapHelper.getBytesFromAsset(
                                        'assets/download.jpeg'),
                                  );
                                  await _controller?.buildAndStartNavigation(
                                    wayPoints: wayPoints,
                                  );
                                  _isRunning = true;
                                },
                                onRouteProgressChange:
                                    (RouteProgressEvent routeProgressEvent) {
                                  setState(() {
                                    this.routeProgressEvent =
                                        routeProgressEvent;
                                  });
                                  _setInstructionImage(
                                    routeProgressEvent.currentModifier,
                                    routeProgressEvent.currentModifierType,
                                  );
                                },
                                // onArrival: () {
                                //   _isRunning = false;
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(
                                //       content: Container(
                                //         height: 100,
                                //         color: Pallete.primaryColor,
                                //         child:
                                //             const Text('Bạn đã đến điểm đón'),
                                //       ),
                                //     ),
                                //   );
                                // },
                              ),
                              !_isRunning
                                  ? const SizedBox.shrink()
                                  : Positioned(
                                      top: MediaQuery.of(context)
                                          .viewPadding
                                          .top,
                                      left: 0,
                                      child: BannerInstructionView(
                                        routeProgressEvent: routeProgressEvent,
                                        instructionIcon: instructionImage,
                                      ),
                                    ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onVerticalDragUpdate: (details) {
                                    // Adjust height based on the swipe direction
                                    setState(
                                      () {
                                        _containerHeight +=
                                            details.primaryDelta!;
                                        _containerHeight =
                                            _containerHeight.clamp(60.0, 300.0);
                                      },
                                    );
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
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            vertical: 10.0,
                                                            horizontal: 16.0,
                                                          ),
                                                          child: Text(
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            widget
                                                                    .trip
                                                                    ?.startLocation
                                                                    .address ??
                                                                '',
                                                            textAlign:
                                                                TextAlign.start,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      ref
                                                          .watch(
                                                              isPassengerInformationOnProvider
                                                                  .notifier)
                                                          .setIsPassengerInformation(
                                                              true);
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Column(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundColor:
                                                                Colors.black54,
                                                            radius: 20,
                                                            child: Icon(
                                                              color:
                                                                  Colors.white,
                                                              IconData(
                                                                0xf74d,
                                                                fontFamily:
                                                                    CupertinoIcons
                                                                        .iconFont,
                                                                fontPackage:
                                                                    CupertinoIcons
                                                                        .iconFontPackage,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  4), // Adjust the spacing as needed
                                                          Text(
                                                            'Thông tin',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700 // Adjust the font size as needed
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 16.0,
                                                      ),
                                                      child: Text(
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                        widget.trip?.note ?? '',
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      // setState(() {
                                                      //   _isChatOn = true;
                                                      // });
                                                      ref
                                                          .watch(
                                                              isChatOnProvider
                                                                  .notifier)
                                                          .setIsChatOnData(
                                                              true);
                                                      // navigateToChat(
                                                      //   widget.trip?.booker.id ?? '',
                                                      // );
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Column(
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundColor:
                                                                Colors.black54,
                                                            radius: 20,
                                                            child: Icon(
                                                              color:
                                                                  Colors.white,
                                                              IconData(0xe153,
                                                                  fontFamily:
                                                                      'MaterialIcons'),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  4), // Adjust the spacing as needed
                                                          Text(
                                                            'Chat',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700 // Adjust the font size as needed
                                                                ),
                                                          ),
                                                        ],
                                                      ),
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.greenAccent[700],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    // locationData =
                                                    //     await location.getCurrentLocation();
                                                    if (context.mounted) {
                                                      final location = ref.read(
                                                          locationProvider);
                                                      locationData = await location
                                                          .getCurrentLocation();
                                                      if (mounted) {
                                                        if (widget.trip?.type ==
                                                            TripType
                                                                .bookForDepNoApp
                                                                .value) {
                                                          await takePictureToPickup();
                                                          print(
                                                              pickupPictureFile
                                                                  ?.path);
                                                        }
                                                        if (mounted) {
                                                          final tripResult = await ref
                                                              .watch(
                                                                  tripControllerProvider
                                                                      .notifier)
                                                              .confirmPickUpPassenger(
                                                                context,
                                                                locationData
                                                                    ?.latitude,
                                                                locationData
                                                                    ?.longitude,
                                                                pickupPictureFile
                                                                    ?.path,
                                                                widget.trip
                                                                        ?.id ??
                                                                    '',
                                                              );
                                                          if (tripResult !=
                                                              null) {
                                                            if (tripResult.id
                                                                .isNotEmpty) {
                                                              _controller
                                                                  ?.clearRoute();
                                                              _controller
                                                                  ?.finishNavigation();
                                                              _onStopNavigation();
                                                              navigateToDeliverPassenger();
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  },
                                                  child: const Text(
                                                    'Đón khách',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
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
                  ),
                ),
    );
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
}
