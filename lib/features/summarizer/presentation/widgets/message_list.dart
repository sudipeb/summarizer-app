import 'package:flutter/material.dart';
import 'package:summarizer/features/summarizer/presentation/widgets/chat_bubble.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text('Enter text below and tap send to summarize.'),
      );
    }
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return ChatBubble(
          text: msg['text'] as String,
          isUser: msg['isUser'] as bool,
          copyable: msg['placeholder'] != true,
        );
      },
    );
  }
}
