import 'package:flutter/material.dart';
import 'package:summarizer/features/summarizer/presentation/blocs/summarizer_cubit.dart';
import 'package:summarizer/features/summarizer/presentation/widgets/chat_bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextSummarizer extends StatefulWidget {
  final String? endpoint;
  const TextSummarizer({super.key, this.endpoint});

  @override
  State<TextSummarizer> createState() => _TextSummarizerState();
}

class _TextSummarizerState extends State<TextSummarizer> {
  final controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SummarizerCubit(endpoint: widget.endpoint),
      child: BlocListener<SummarizerCubit, SummarizerState>(
        listener: (context, state) {
          if (state.isLoading) return;

          final text = state.summary ?? state.errorMessage;
          if (text == null || text.isEmpty) return;

          setState(() {
            messages.add({'text': text, 'isUser': false});
          });

          _scrollToBottom();
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Summarizer'), automaticallyImplyLeading: true),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: messages.isEmpty
                        ? const Center(child: Text('Enter text below and tap send to summarize.'))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              return ChatBubble(text: msg['text'] as String, isUser: msg['isUser'] as bool);
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<SummarizerCubit, SummarizerState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          if (state.isLoading)
                            const Padding(padding: EdgeInsets.only(bottom: 8), child: LinearProgressIndicator()),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.newline,
                                  decoration: const InputDecoration(
                                    hintText: 'Paste or type text to summarize',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: state.isLoading
                                    ? null
                                    : () async {
                                        final input = controller.text.trim();
                                        if (input.isEmpty) return;

                                        setState(() {
                                          messages.add({'text': input, 'isUser': true});
                                        });

                                        _scrollToBottom();

                                        controller.clear();
                                        await context.read<SummarizerCubit>().summarizeText(input);
                                      },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
