import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  Icons.link,
                  color: state.isConnected ? Colors.grey : Colors.green,
                ),
                onPressed:
                    state.isConnected
                        ? null
                        : () =>
                            context.read<ChatBloc>().add(ConnectToWebSocket()),
                tooltip: 'Connect',
              );
            },
          ),
          Text('Chat App'),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  Icons.link_off,
                  color: !state.isConnected ? Colors.grey : Colors.red,
                ),
                onPressed:
                    !state.isConnected
                        ? null
                        : () => context.read<ChatBloc>().add(
                          DisconnectFromWebSocket(),
                        ),
                tooltip: 'Disconnect',
              );
            },
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
