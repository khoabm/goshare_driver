import 'package:flutter_riverpod/flutter_riverpod.dart';

final isChatOnProvider = StateNotifierProvider<IsChatOnNotifier, bool>((ref) {
  return IsChatOnNotifier();
});

class IsChatOnNotifier extends StateNotifier<bool> {
  IsChatOnNotifier() : super(false);
  bool get isChatOn => state;
  void setIsChatOnData(bool isChatOn) {
    state = isChatOn;
  }
}

final isPassengerInformationOnProvider =
    StateNotifierProvider<IsPassengerInformationNotifier, bool>((ref) {
  return IsPassengerInformationNotifier();
});

class IsPassengerInformationNotifier extends StateNotifier<bool> {
  IsPassengerInformationNotifier() : super(false);
  bool get isPassengerInformation => state;
  void setIsPassengerInformation(bool isPassengerInformation) {
    state = isPassengerInformation;
  }
}
