import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  WebSocketChannel? channel;
  StreamSubscription? subscription;

  ChatBloc() : super(ChatState()) {
    on<ConnectToWebSocket>(onConnectToWebSocket);
    on<SendChatMessage>(onSendChatMessage);
    on<ReceiveChatMessage>(onReceiveChatMessage);
    on<DisconnectFromWebSocket>(onDisconnectFromWebSocket);
  }

  void onConnectToWebSocket(ConnectToWebSocket event, Emitter<ChatState> emit) async {
    try {
      channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org/'));
      emit(state.copyWith(isConnected: true));

      subscription = channel!.stream.listen(
            (message) {
          add(ReceiveChatMessage('Received: $message'));
        },
        onError: (error) {
          emit(state.copyWith(isConnected: false));
          addError('WebSocket error: $error');
        },
        onDone: () {
          emit(state.copyWith(isConnected: false));
        },
        cancelOnError: true,
      );
    } catch (e, stackTrace) {
      emit(state.copyWith(isConnected: false));
      addError('Failed to connect to WebSocket: $e', stackTrace);
    }
  }

  void onSendChatMessage(SendChatMessage event, Emitter<ChatState> emit) {
    if (state.isConnected && channel != null) {
      try {
        channel!.sink.add(event.message);
        final updatedMessages = List<String>.from(state.messages)..add('You: ${event.message}');
        emit(state.copyWith(messages: updatedMessages));
      } catch (e, stackTrace) {
        addError('Error sending message: $e', stackTrace);
      }
    }
  }

  void onReceiveChatMessage(ReceiveChatMessage event, Emitter<ChatState> emit) {
    final updatedMessages = List<String>.from(state.messages)..add(event.message);
    emit(state.copyWith(messages: updatedMessages));
  }

  void onDisconnectFromWebSocket(DisconnectFromWebSocket event, Emitter<ChatState> emit) {
    try {
      subscription?.cancel();
      channel?.sink.close();
      emit(ChatState());
    } catch (e, stackTrace) {
      addError('Error disconnecting WebSocket: $e', stackTrace);
    }
  }

  @override
  Future<void> close() {
    try {
      subscription?.cancel();
      channel?.sink.close();
    } catch (e, stackTrace) {
      addError('Error closing WebSocket: $e', stackTrace);
    }
    return super.close();
  }
}
