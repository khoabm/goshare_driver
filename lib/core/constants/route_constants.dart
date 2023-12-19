class RouteConstants {
  ///**
  ///Route name constants
  /// */

  static const dashBoard = 'dashboard';
  static const tripRequest = 'trip-request';
  static const pickUpPassenger = 'pick-up';
  static const passengerInformation = 'passenger-information';
  static const deliverPassenger = 'deliver-passenger';
  static const chat = 'chat';
  static const login = 'login';
  static const endTrip = 'end-trip';
  static const userInfoRegis = 'user-info-regis';
  static const driverInfoRegis = 'driver-info-regis';
  static const otp = 'otp';
  static const userExistConfirm = 'user-exist-confirm';
  static const setPassCode = 'passcode';
  static const userExistVerify = 'user-exist-verify';
  static const driverRegisSuccess = 'driver-regis-success';
  static const statistic = 'statistic';
  static const editProfile = 'profile';
  static const driverInformationRegister = 'driver-information-register';
  static const tripHistory = 'trip-history';
  static const moneyTopup = 'moneyTopup';

  ///**
  ///Route url constants
  /// */

  static const dashBoardUrl = '/';
  static const tripRequestUrl = '/trip-request';
  static const pickUpPassengerUrl = '/pick-up';
  static const passengerInformationUrl = '/passenger-information';
  static const chatUrl = 'chat/:receiver';
  static const deliverPassengerUrl = '/deliver-passenger';
  static const loginUrl = '/login';
  static const endTripUrl = '/end-trip';
  static const userInfoRegisUrl = '/user-info-regis';
  static const driverInfoRegisUrl = '/driver-info-regis/:phone';
  static const driverInformationRegisterUrl =
      '/driver-information-register/:passcode';
  static const otpUrl = '/otp/:phone';
  static const userExistConfirmUrl = '/user-exist-confirm';
  static const passcodeUrl = '/passcode/:setToken/:phone';
  static const userExistVerifyUrl = '/user-exist-verify';
  static const driverRegisSuccessUrl = '/driver-regis-success';
  static const statisticUrl = '/statistic';
  static const editProfileUrl = '/profile';
  static const tripHistoryUrl = '/trip-history';
  static const moneyTopupUrl = '/moneyTopup';
}
