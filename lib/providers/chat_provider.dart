import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goshare_driver/features/trip/screens/chat_screen.dart';

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
        (ref) => ChatMessagesNotifier());

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {

  ChatMessagesNotifier()
      : super(
          [],
        );



  void addMessage(ChatMessage message) {
    state = [...state, message];
  }
}
