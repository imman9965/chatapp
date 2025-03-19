class ChatState {
  final bool isConnected;
  final List<String> messages;
  final String? error;

  ChatState({
    this.isConnected = false,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isConnected,
    List<String>? messages,
    String? error,
  }) {
    return ChatState(
      isConnected: isConnected ?? this.isConnected,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}