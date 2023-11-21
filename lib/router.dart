import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/page_navigation.dart';
import 'package:goshare_driver/features/dashboard/screen/dashboard.dart';
import 'package:goshare_driver/features/pick-up-passenger/screens/pick_up_passenger_screen.dart';
import 'package:goshare_driver/features/trip-request/screens/trip_request_screen.dart';
import 'package:goshare_driver/models/trip_model.dart';

class AppRouter {
  /// The route configuration.
  final GoRouter router = GoRouter(
    initialLocation: RouteConstants.pickUpPassengerUrl, //'/find-trip',
    routes: <RouteBase>[
      GoRoute(
        name: RouteConstants.dashBoard,
        path: RouteConstants.dashBoardUrl,
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
        ) {
          return SlideRightTransition(
            child: const DashBoard(),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        name: RouteConstants.tripRequest,
        path: RouteConstants.tripRequestUrl,
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
        ) {
          final trip = state.extra as List<dynamic>?;
          return SlideRightTransition(
            child: TripRequest(trip),
            key: state.pageKey,
          );
        },
      ),
      GoRoute(
        name: RouteConstants.pickUpPassenger,
        path: RouteConstants.pickUpPassengerUrl,
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
        ) {
          final trip = state.extra as Trip?;
          return SlideRightTransition(
            child: PickUpPassenger(trip: trip),
            key: state.pageKey,
          );
        },
      ),
    ],
  );
}
