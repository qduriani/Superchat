import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superchat/messages/messages_bloc.dart';
import 'package:superchat/pages/chat_page.dart';
import 'package:superchat/pages/sign_in_page.dart';

class MessagesListPage extends StatelessWidget {
  const MessagesListPage({super.key});

  Color invertColor(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB((color.opacity * 255).round(), r, g, b);
  }

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
                  final rowColor = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
                  return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ChatPage(
                                state.currentUser.id, 
                                state.users[index].id,
                                state.users[index].displayName,
                        )));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          color: rowColor,
                        ), 
                        child: Row(children: [
                          const Padding(padding: EdgeInsets.all(8)),
                          Icon(
                            Icons.person,
                            color: rowColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                state.users[index].displayName, 
                                style: TextStyle(
                                  color: rowColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                )
                              )
                            )
                          )
                        ])
                      ));
                });
          }
          return const Center(child: Text('Error loading users.'));
        })));
  }
}
