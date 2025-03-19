import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  WebSocketChannel? channel;
  StreamSubscription? subscription;

  ChatBloc() : super(ChatState()) {
    on<ConnectToWebSocket>(onConnectToWebSocket);
    on<SendChatMessage>(onSendChatMessage);
    on<ReceiveChatMessage>(onReceiveChatMessage);
    on<DisconnectFromWebSocket>(onDisconnectFromWebSocket);
  }

  Future<void> onConnectToWebSocket(
    ConnectToWebSocket event,
    Emitter<ChatState> emit,
  ) async {
    try {
      print('Checking network connectivity...');
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection');
        emit(
          state.copyWith(isConnected: false, error: 'No internet connection'),
        );
        return;
      }

      channel = WebSocketChannel.connect(
        Uri.parse('wss://echo.websocket.org/'),
      );
      print('WebSocket connected successfully');
      emit(state.copyWith(isConnected: true, error: null));

      subscription = channel!.stream.listen(
        (message) {
          print('Received: $message');
          add(ReceiveChatMessage('Received: $message'));
        },
        onError: (error) {
          print('WebSocket error: $error');
          emit(
            state.copyWith(
              isConnected: false,
              error: 'WebSocket error: $error',
            ),
          );
        },
        onDone: () {
          print('WebSocket closed with code: ${channel?.closeCode}');
          emit(state.copyWith(isConnected: false, error: 'WebSocket closed'));
        },
        cancelOnError: true,
      );
    } catch (e, stackTrace) {
      print('Failed to connect to WebSocket: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(isConnected: false, error: 'Failed to connect: $e'));
      addError('Failed to connect to WebSocket: $e', stackTrace);
    }
  }

  void onSendChatMessage(SendChatMessage event, Emitter<ChatState> emit) {
    if (state.isConnected && channel != null) {
      try {
        print('Sending: ${event.message}');
        channel!.sink.add(event.message);
        final updatedMessages = List<String>.from(state.messages)
          ..add('You: ${event.message}');
        emit(state.copyWith(messages: updatedMessages, error: null));
      } catch (e, stackTrace) {
        print('Error sending message: $e\nStackTrace: $stackTrace');
        emit(state.copyWith(error: 'Error sending message: $e'));
        addError('Error sending message: $e', stackTrace);
      }
    } else {
      print('Cannot send message: WebSocket not connected');
      emit(state.copyWith(error: 'WebSocket not connected'));
    }
  }

  void onReceiveChatMessage(ReceiveChatMessage event, Emitter<ChatState> emit) {
    print('Received message added: ${event.message}');
    final updatedMessages = List<String>.from(state.messages)
      ..add(event.message);
    emit(state.copyWith(messages: updatedMessages, error: null));
  }

  void onDisconnectFromWebSocket(
    DisconnectFromWebSocket event,
    Emitter<ChatState> emit,
  ) {
    try {
      print('Disconnecting WebSocket');
      subscription?.cancel();
      channel?.sink.close();
      print('WebSocket disconnected');
      emit(ChatState());
    } catch (e, stackTrace) {
      print('Error disconnecting WebSocket: $e\nStackTrace: $stackTrace');
      emit(state.copyWith(error: 'Error disconnecting: $e'));
      addError('Error disconnecting WebSocket: $e', stackTrace);
    }
  }

  @override
  Future<void> close() {
    try {
      print('Closing ChatBloc');
      subscription?.cancel();
      channel?.sink.close();
    } catch (e, stackTrace) {
      print('Error closing WebSocket: $e\nStackTrace: $stackTrace');
      addError('Error closing WebSocket: $e', stackTrace);
    }
    return super.close();
  }
}
