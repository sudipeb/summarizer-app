import 'dart:async';

import 'package:flutter/material.dart';
import 'package:summarizer/features/summarizer/presentation/blocs/summarizer_cubit.dart';
import 'package:summarizer/features/summarizer/presentation/widgets/chat_bubble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:summarizer/core/services/history_service.dart';
import 'package:flutter/services.dart';

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
  String? _pendingQuery;

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
          final query = _pendingQuery;

          // Remove any placeholder 'Summarizing...' bubble before adding real response
          setState(() {
            final placeholderIndex = messages.lastIndexWhere((m) => m['placeholder'] == true);
            if (placeholderIndex != -1) messages.removeAt(placeholderIndex);

            messages.add({'text': text, 'isUser': false});
          });

          if (query != null && state.summary != null) {
            final title = _makeTitle(query);
            unawaited(HistoryService.addEntry(title: title, query: query, answer: state.summary!));
          }

          _pendingQuery = null;

          _scrollToBottom();
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            toolbarHeight: 76,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.indigo.shade900],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8)),
                ],
              ),
            ),
            leading: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
                ),
              ),
              icon: const Icon(Icons.history_rounded),
              onPressed: () {
                final entries = HistoryService.getAllEntries();
                showModalBottomSheet<void>(
                  context: context,
                  builder: (ctx) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Search history'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_forever),
                              onPressed: () async {
                                final navigator = Navigator.of(ctx);
                                await HistoryService.clear();
                                navigator.pop();
                              },
                            ),
                          ),
                          if (entries.isEmpty)
                            const Padding(padding: EdgeInsets.all(16), child: Text('No history yet.'))
                          else
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: entries.length,
                                itemBuilder: (c, i) {
                                  final entry = entries[i];
                                  return ListTile(
                                    title: Text(_historyTitle(entry)),
                                    subtitle: entry.query.isEmpty ? null : Text(_historyPreview(entry.query)),
                                    onTap: () {
                                      _loadHistoryEntry(entry);
                                      setState(() {
                                        controller.text = entry.query.isEmpty ? entry.title : entry.query;
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                    trailing: IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: entry.answer.isEmpty ? entry.query : entry.answer),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Summarizer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.2, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.lightGreenAccent.shade100, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Local cache enabled',
                      style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: const Text(
                    'Token saver',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
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
                              return ChatBubble(
                                text: msg['text'] as String,
                                isUser: msg['isUser'] as bool,
                                copyable: msg['placeholder'] != true,
                              );
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
                                        final summarizerCubit = context.read<SummarizerCubit>();

                                        _pendingQuery = input;

                                        setState(() {
                                          messages.add({'text': input, 'isUser': true});
                                          messages.add({
                                            'text': 'Summarizing...',
                                            'isUser': false,
                                            'placeholder': true,
                                          });
                                        });

                                        _scrollToBottom();

                                        controller.clear();
                                        await summarizerCubit.summarizeText(input);
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

  String _makeTitle(String text) {
    final s = text.replaceAll('\n', ' ').trim();
    if (s.isEmpty) return '';
    final words = s.split(RegExp(r'\s+'));
    final gist = words.take(6).join(' ');
    if (words.length <= 6 && gist.length <= 40) return gist;
    return '${gist.length <= 40 ? gist : gist.substring(0, 40)}...';
  }

  String _historyTitle(HistoryRecord entry) {
    final source = entry.query.isNotEmpty ? entry.query : entry.title;
    final gist = _makeTitle(source);
    return gist.isEmpty ? 'History item' : gist;
  }

  String _historyPreview(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.isEmpty) return '';
    if (clean.length <= 60) return clean;
    return '${clean.substring(0, 57)}...';
  }

  void _loadHistoryEntry(HistoryRecord entry) {
    setState(() {
      messages.clear();
      if (entry.query.isNotEmpty) {
        messages.add({'text': entry.query, 'isUser': true});
      }
      if (entry.answer.isNotEmpty) {
        messages.add({'text': entry.answer, 'isUser': false});
      }
      controller.text = entry.query.isEmpty ? entry.title : entry.query;
    });

    _scrollToBottom();
  }
}
