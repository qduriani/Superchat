import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superchat/messages/messages_bloc.dart';
import 'package:superchat/pages/chat_page.dart';
import 'package:superchat/pages/sign_in_page.dart';

class MessagesListPage extends StatelessWidget {
  const MessagesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessagesBloc()..add(MessagesInitialEvent()),
        child: BlocListener<MessagesBloc, MessagesState>(listener:
            (context, state) {
          if (state is MessagesAuthDisconnected) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInPage()),
                (route) => false);
          }
        }, child:
            BlocBuilder<MessagesBloc, MessagesState>(builder: (context, state) {
          if (state is MessagesLoadedUsers) {
            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.users.length,
                itemBuilder: (BuildContext listContext, int index) {
                  return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChatPage(
                                state.currentUser.id, state.users[index].id)));
                      },
                      child: SizedBox(
                        height: 50,
                        child:
                            Center(child: Text(state.users[index].displayName)),
                      ));
                });
          }
          return const Center(child: Text('Error loading users.'));
        })));
  }
}
