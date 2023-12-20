import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:superchat/messages/messages_bloc.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(this.id, this.participantId, {super.key});

  final String id;
  final String participantId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String _id;
  late String _participantId;

  late types.User _user;
  List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _id = widget.id;
    _participantId = widget.participantId;
    _user = types.User(id: widget.id);
  }

  types.Message? addMissingFields(Map<String, dynamic> data) {
    try {
      data["createdAt"] =
          (data["timestamp"] as Timestamp).toDate().millisecondsSinceEpoch;
      data["author"] =
          types.User(id: data["from"] == _participantId ? _participantId : _id)
              .toJson();
      data["text"] = data["content"];
      data["id"] = const Uuid().v4();
      data["type"] = types.MessageType.text.name;
      return types.Message.fromJson(data);
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: BlocProvider(
          create: (context) => MessagesBloc()
            ..add(MessagesLoadedChatEvent(participantId: _participantId)),
          child: BlocBuilder<MessagesBloc, MessagesState>(
              builder: (context, state) {
            if (state is MessagesLoadedChat) {
              return StreamBuilder(
                  stream: state.messages,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _messages = snapshot.data
                              ?.map((e) => addMissingFields(e))
                              .nonNulls
                              .toList() ??
                          [];
                      _messages.sort((a, b) =>
                          (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

                      return Chat(
                        messages: _messages,
                        // onAttachmentPressed: _handleAttachmentPressed,
                        // onMessageTap: _handleMessageTap,
                        // onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: (partialText) => state.sendNewMessage(
                            partialText, _id, _participantId),
                        showUserAvatars: true,
                        showUserNames: true,
                        user: _user,
                      );
                    } else {
                      return const Text("Error");
                    }
                  });
            } else {
              return const Text("Error");
            }
          })));
}
