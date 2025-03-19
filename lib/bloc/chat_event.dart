abstract class ChatEvent {}

class ConnectToWebSocket extends ChatEvent {}

class SendChatMessage extends ChatEvent {
  final String message;
  SendChatMessage(this.message);
}

class ReceiveChatMessage extends ChatEvent {
  final String message;
  ReceiveChatMessage(this.message);
}

class DisconnectFromWebSocket extends ChatEvent {}