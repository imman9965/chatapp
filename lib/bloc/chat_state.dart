class ChatState {
  final bool isConnected;
  final List<String> messages;

  ChatState({
    this.isConnected = false,
    this.messages = const [],
  });

  ChatState copyWith({
    bool? isConnected,
    List<String>? messages,
  }) {
    return ChatState(
      isConnected: isConnected ?? this.isConnected,
      messages: messages ?? this.messages,
    );
  }
}