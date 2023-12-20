part of 'messages_bloc.dart';

sealed class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object> get props => [];
}

final class MessagesInitial extends MessagesState {}

final class MessagesLoadedUsers extends MessagesState {
  final List<UserModel> users;
  final UserModel currentUser;
  const MessagesLoadedUsers({required this.users, required this.currentUser});

  @override
  List<Object> get props => [users];
}

final class MessagesAuthDisconnected extends MessagesState {}

final class MessagesLoadedChat extends MessagesState {
  final Stream<List<Map<String, dynamic>>> messages;

  const MessagesLoadedChat({required this.messages});

  @override
  List<Object> get props => [messages];

  void sendNewMessage(
      types.PartialText partialText, String id, String participantId) {
    Map<String, dynamic> msg = {
      "from": id,
      "to": participantId,
      "timestamp": Timestamp.now(),
      "content": partialText.text,
    };
    Repository.sendMessage(msg);
  }
}
