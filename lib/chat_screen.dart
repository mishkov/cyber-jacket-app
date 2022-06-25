import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static const route = '/chat';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Send Test Message'),
        ),
      ),
    );
  }
}
