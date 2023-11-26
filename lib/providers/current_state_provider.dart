import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentStateProvider =
    StateNotifierProvider<CurrentStateNotifier, bool>((ref) {
  return CurrentStateNotifier();
});

class CurrentStateNotifier extends StateNotifier<bool> {
  CurrentStateNotifier() : super(false);
  bool get currentState => state;
  void setCurrentStateData(bool currentState) {
    state = currentState;
  }
}
