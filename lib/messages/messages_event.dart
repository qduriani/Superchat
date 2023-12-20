part of 'messages_bloc.dart';

sealed class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object> get props => [];
}

final class MessagesInitialEvent extends MessagesEvent {}

final class MessagesAuthDisconnectedEvent extends MessagesEvent {}

final class MessagesLoadedChatEvent extends MessagesEvent {
  final String participantId;

  const MessagesLoadedChatEvent({required this.participantId});
}
