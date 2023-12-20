import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:superchat/repository.dart';
import 'package:superchat/users/user_model.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc() : super(MessagesInitial()) {
    on<MessagesInitialEvent>((event, emit) async {
      String id = Repository.getCurrentUser()?.uid ?? "";
      List<UserModel> users = await Repository.getUsers(id);
      UserModel? currentUser = await Repository.getUser(id);
      emit(MessagesLoadedUsers(users: users, currentUser: currentUser!));
    });

    on<MessagesAuthDisconnectedEvent>((event, emit) {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          emit(MessagesAuthDisconnected());
        }
      });
    });

    on<MessagesLoadedChatEvent>((event, emit) {
      String id = Repository.getCurrentUser()?.uid ?? "";
      Stream<List<Map<String, dynamic>>> messages =
          Repository.fetchMessages(id, event.participantId);
      emit(MessagesLoadedChat(messages: messages));
    });
  }
}
