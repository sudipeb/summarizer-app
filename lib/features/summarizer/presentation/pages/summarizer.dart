import 'dart:async';

import 'package:flutter/material.dart';
import 'package:summarizer/features/summarizer/presentation/blocs/summarizer_cubit.dart';
import 'package:summarizer/features/summarizer/presentation/widgets/message_list.dart';
import 'package:summarizer/features/summarizer/presentation/widgets/input_bar.dart';
import 'package:summarizer/features/summarizer/presentation/widgets/history_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:summarizer/core/services/history_service.dart';

class TextSummarizer extends StatefulWidget {
  const TextSummarizer({super.key, this.endpoint});

  final String? endpoint;

  @override
  State<TextSummarizer> createState() => _TextSummarizerState();
}

class _TextSummarizerState extends State<TextSummarizer> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  String? _pendingQuery;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _handleSubmit(BuildContext ctx, String input) async {
    if (input.trim().isEmpty) return;
    final summarizerCubit = ctx.read<SummarizerCubit>();

    _pendingQuery = input;

    setState(() {
      _messages.add({'text': input, 'isUser': true});
      _messages.add({'text': 'Summarizing...', 'isUser': false, 'placeholder': true});
    });

    _scrollToBottom();
    _controller.clear();
    await summarizerCubit.summarizeText(input);
  }

  void _onStateChanged(BuildContext context, SummarizerState state) {
    if (state.isLoading) return;

    final text = state.summary ?? state.errorMessage;
    if (text == null || text.isEmpty) return;

    setState(() {
      final placeholderIndex = _messages.lastIndexWhere((m) => m['placeholder'] == true);
      if (placeholderIndex != -1) _messages.removeAt(placeholderIndex);

      _messages.add({'text': text, 'isUser': false});
    });

    if (_pendingQuery != null && state.summary != null) {
      final title = _makeTitle(_pendingQuery!);
      unawaited(HistoryService.addEntry(title: title, query: _pendingQuery!, answer: state.summary!));
    }

    _pendingQuery = null;
    _scrollToBottom();
  }

  void _showHistorySheet() async {
    final result = await showModalBottomSheet<HistoryRecord>(
      context: context,
      builder: (_) => const HistoryBottomSheet(),
    );

    if (result != null) {
      _loadHistoryEntry(result);
    }
  }

  void _loadHistoryEntry(HistoryRecord entry) {
    setState(() {
      _messages.clear();
      if (entry.query.isNotEmpty) {
        _messages.add({'text': entry.query, 'isUser': true});
      }
      if (entry.answer.isNotEmpty) {
        _messages.add({'text': entry.answer, 'isUser': false});
      }
      _controller.text = entry.query.isEmpty ? entry.title : entry.query;
    });
    _scrollToBottom();
  }

  String _makeTitle(String text) {
    final s = text.replaceAll('\n', ' ').trim();
    if (s.isEmpty) return '';
    final words = s.split(RegExp(r'\s+'));
    final gist = words.take(6).join(' ');
    if (words.length <= 6 && gist.length <= 40) return gist;
    return '${gist.length <= 40 ? gist : gist.substring(0, 40)}...';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SummarizerCubit(endpoint: widget.endpoint),
      child: Builder(
        builder: (builderContext) => BlocListener<SummarizerCubit, SummarizerState>(
          listener: (ctx, state) => _onStateChanged(ctx, state),
          child: Scaffold(
            appBar: _buildAppBar(),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: MessageList(messages: _messages, scrollController: _scrollController),
                    ),
                    const SizedBox(height: 8),
                    InputBar(controller: _controller, onSubmit: (input) => _handleSubmit(builderContext, input)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      leading: _buildHistoryButton(),
      title: _buildTitle(),
      actions: const [_BuildTokenSaverBadge()],
    );
  }

  Widget _buildHistoryButton() {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.14),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
      ),
      icon: const Icon(Icons.history_rounded),
      onPressed: _showHistorySheet,
    );
  }

  Widget _buildTitle() {
    return Column(
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
    );
  }
}

class _BuildTokenSaverBadge extends StatelessWidget {
  const _BuildTokenSaverBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
