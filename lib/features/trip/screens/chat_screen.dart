import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:goshare_driver/features/auth/screens/sign_in_screen.dart';
import 'package:goshare_driver/features/trip/controller/trip_controller.dart';
import 'package:goshare_driver/models/chat_model.dart';
// import 'package:goshare_driver/providers/chat_provider.dart';
// import 'package:goshare_driver/providers/is_chat_on_provider.dart';
import 'package:goshare_driver/providers/signalr_providers.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatMessage {
  final String message;
  final bool isCurrentUser;

  ChatMessage(this.message, this.isCurrentUser);
}

class ChatScreen extends ConsumerStatefulWidget {
  final String receiver;
  final String? bookerAvatar;
  final String tripId;
  const ChatScreen({
    super.key,
    required this.receiver,
    this.bookerAvatar,
    required this.tripId,
  });

  @override
  ConsumerState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<ChatModel> _messages = [];
  // List<ChatModel> chats = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initSignalR(ref);
      if (mounted) {
        _messages = await ref.read(tripControllerProvider.notifier).getChat(
              context,
              widget.tripId,
            );
        _messages = _messages.reversed.toList();
      }
      setState(() {});
    });
  }

  ChatMessage chatModelToChatMessage(ChatModel chatModel, String userId) {
    return ChatMessage(
      chatModel.content,
      chatModel.from == userId,
    );
  }

  List<ChatMessage> chatModelsToChatMessages(
      List<ChatModel> chatModels, String userId) {
    return chatModels
        .map((chatModel) => chatModelToChatMessage(chatModel, userId))
        .toList();
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ref.watch(tripControllerProvider.notifier).sendChat(
          context,
          text,
          widget.receiver,
          widget.tripId,
        );
    setState(() {
      // Assuming you have userId available here
      _messages.insert(
        0,
        ChatModel(
          from: ref.read(userProvider)?.id ?? '',
          to: widget.receiver,
          content: text,
          time: DateTime.now(),
        ),
      );
    });
  }

  Future<void> initSignalR(WidgetRef ref) async {
    try {
      final hubConnection = await ref.watch(
        hubConnectionProvider.future,
      );

      hubConnection.on('ReceiveSMSMessages', (message) {
        if (mounted) {
          print(
              "${message.toString()} DAY ROI SIGNAL R DAY ROI RECEIVE SMS MESSAGE");
          setState(() {
            // _messages.insert(
            //     0, ChatMessage(message?.first.toString() ?? '', false));
            _messages.insert(
              0,
              ChatModel(
                from: widget.receiver,
                to: ref.read(userProvider)?.id ?? '',
                content: message?.first.toString() ?? '',
                time: DateTime.now(),
              ),
            );
          });
        }
      });

      hubConnection.onclose((exception) async {
        print(exception.toString() + "LOI CUA SIGNALR ON CLOSE");
        await Future.delayed(
          const Duration(seconds: 3),
          () async {
            if (hubConnection.state == HubConnectionState.disconnected) {
              await hubConnection.start();
            }
          },
        );
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  const InputDecoration.collapsed(hintText: "Gửi tin nhắn"),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: message.isCurrentUser
                ? const CircleAvatar(
                    radius: 10.0,
                    child: Text('Tôi'),
                  )
                : Center(
                    child: CircleAvatar(
                      radius: 10.0,
                      backgroundImage: NetworkImage(
                        widget.bookerAvatar ??
                            'https://firebasestorage.googleapis.com/v0/b/goshare-bc3c4.appspot.com/o/7b0ae9e0-013b-4213-9e33-3321fda277b3%2F7b0ae9e0-013b-4213-9e33-3321fda277b3_avatar?alt=media',
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(message.isCurrentUser ? 'Me' : 'You'),
              Container(
                margin: const EdgeInsets.only(top: 5.0),
                child: Text(message.message),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nhắn tin'),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _buildMessage(
                chatModelToChatMessage(
                  _messages[index],
                  ref.read(userProvider)?.id ?? '',
                ),
              ),
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}
