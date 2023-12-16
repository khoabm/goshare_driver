import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/core/constants/route_constants.dart';
import 'package:goshare_driver/core/page_navigation.dart';
import 'package:goshare_driver/features/auth/screens/driver_info_regis_screen.dart';
import 'package:goshare_driver/features/auth/screens/otp_screen.dart';
import 'package:goshare_driver/features/auth/screens/regis_success_screen.dart';
import 'package:goshare_driver/features/auth/screens/set_passcode_screen.dart';
import 'package:goshare_driver/features/auth/screens/sign_in_screen.dart';
import 'package:goshare_driver/features/auth/screens/user_exist_confirm_screen.dart';
import 'package:goshare_driver/features/auth/screens/user_exist_verify.dart';
import 'package:goshare_driver/features/auth/screens/user_info_regis_screen.dart';
import 'package:goshare_driver/features/dashboard/screen/dashboard.dart';
import 'package:goshare_driver/features/dashboard/screen/profile_screen.dart';
import 'package:goshare_driver/features/dashboard/screen/statistics_screen.dart';
import 'package:goshare_driver/features/trip/screens/chat_screen.dart';
import 'package:goshare_driver/features/trip/screens/deliver_passenger_screen.dart';
import 'package:goshare_driver/features/trip/screens/passenger_information_screen.dart';
import 'package:goshare_driver/features/trip/screens/payment_result_screen.dart';
import 'package:goshare_driver/features/trip/screens/pick_up_passenger_screen.dart';
import 'package:goshare_driver/features/trip-request/screens/trip_request_screen.dart';
import 'package:goshare_driver/models/end_trip_model.dart';
import 'package:goshare_driver/models/trip_model.dart';
import 'package:goshare_driver/driver_information_register_screen.dart';

class AppRouter {
  /// The route configuration.
  GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      // initialLocation, //RouteConstants.statisticUrl, //'/test3',  //'/find-trip',
      routes: <RouteBase>[
        GoRoute(
          name: RouteConstants.login,
          path: RouteConstants.loginUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const LogInScreen(),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: 'test',
          path: '/test',
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: PickUpPassenger(
                trip: Trip(
                  id: '123',
                  passengerId: '123',
                  driverId: '123',
                  startLocationId: '123',
                  endLocationId: '123',
                  distance: 10,
                  price: 123,
                  cartypeId: '123',
                  status: 1,
                  paymentMethod: 0,
                  bookerId: '123',
                  passenger: Passenger(
                      id: '123', name: '123', phone: '123', avatarUrl: '123'),
                  booker: Booker(id: '123', name: '123', phone: '123'),
                  endLocation: EndLocation(
                      id: '123',
                      userId: '123',
                      address: '123',
                      latitude: 10.66666666,
                      longitude: 106.6666666),
                  startLocation: StartLocation(
                      id: '123',
                      userId: '123',
                      address: '123',
                      latitude: 10.6666667,
                      longitude: 106.66666667),
                  cartype: CarType(capacity: 4),
                  type: 3,
                ),
              ),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: 'test2',
          path: '/test2',
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const DriverInfoRegisScreen(
                phone: '+84333333331',
              ),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.driverInformationRegister,
          path: RouteConstants.driverInformationRegisterUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final params = state.pathParameters;
            final String passcode = params['passcode'] ?? '';
            return SlideRightTransition(
              child: DriverInformationRegister(
                passcode: passcode,
              ),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.userExistConfirm,
          path: RouteConstants.userExistConfirmUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const UserExistConfirmScreen(),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.userInfoRegis,
          path: RouteConstants.userInfoRegisUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const UserInfoRegisScreen(),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.otp,
          path: RouteConstants.otpUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final params = state.pathParameters;
            final String? phone = params['phone'];
            return SlideRightTransition(
              child: OtpScreen(
                phone: phone ?? '',
              ),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.setPassCode,
          path: RouteConstants.passcodeUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final params = state.pathParameters;
            final String? phone = params['phone'];
            final String? setToken = params['setToken'];
            return SlideRightTransition(
              child: SetPassCodeScreen(
                phone: phone ?? '',
                setToken: setToken ?? '',
              ),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.driverInfoRegis,
          path: RouteConstants.driverInfoRegisUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final params = state.pathParameters;
            final String phone = params['phone']!;
            return SlideRightTransition(
              child: DriverInfoRegisScreen(
                phone: phone,
              ),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.userExistVerify,
          path: RouteConstants.userExistVerifyUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const UserExistVerifyScreen(),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.driverRegisSuccess,
          path: RouteConstants.driverRegisSuccessUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const RegisSuccessScreen(),
              key: state.pageKey,
            );
          },
        ),
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
          routes: [
            GoRoute(
              name: RouteConstants.chat,
              path: RouteConstants.chatUrl,
              pageBuilder: (
                BuildContext context,
                GoRouterState state,
              ) {
                final Map<String, dynamic> params = state.pathParameters;
                final String receiver = params['receiver'] as String;
                return SlideRightTransition(
                  child: ChatScreen(receiver: receiver),
                  key: state.pageKey,
                );
              },
            ),
          ],
        ),
        GoRoute(
          name: RouteConstants.deliverPassenger,
          path: RouteConstants.deliverPassengerUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final trip = state.extra as Trip?;

            return SlideRightTransition(
              child: DeliverPassengerScreen(trip: trip),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.passengerInformation,
          path: RouteConstants.passengerInformationUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final trip = state.extra as Trip?;
            return SlideRightTransition(
              child: PassengerInformationScreen(trip: trip),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.endTrip,
          path: RouteConstants.endTripUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            //final params = state.extra as Map<String, dynamic>;
            final trip = state.extra as EndTripModel?;
            //final String receiver = params['receiver'] as String;
            return SlideRightTransition(
              child: PaymentResultScreen(trip: trip),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.statistic,
          path: RouteConstants.statisticUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const StatisticScreen(),
              key: state.pageKey,
            );
          },
        ),
        GoRoute(
          name: RouteConstants.editProfile,
          path: RouteConstants.editProfileUrl,
          pageBuilder: (
            BuildContext context,
            GoRouterState state,
          ) {
            return SlideRightTransition(
              child: const EditProfilePage(),
              key: state.pageKey,
            );
          },
        ),
      ],
    );
  }
}
