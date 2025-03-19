import 'package:flutter/material.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/message_list.dart';
import '../widgets/message_input.dart';
import '../widgets/connection_status.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(),
      body: Column(
        children: [
          MessageList(),
          MessageInput(controller: _controller),
          ConnectionStatus(),
        ],
      ),
    );
  }
}