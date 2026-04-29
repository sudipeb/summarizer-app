import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:summarizer/core/services/history_service.dart';

class HistoryBottomSheet extends StatelessWidget {
  const HistoryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Search history'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                final navigator = Navigator.of(context);
                await HistoryService.clear();
                navigator.pop();
              },
            ),
          ),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final entries = HistoryService.getAllEntries();
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No history yet.'),
      );
    }
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _HistoryTile(entry: entry);
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryRecord entry;

  const _HistoryTile({required this.entry});

  String _getTitle() {
    final source = entry.query.isNotEmpty ? entry.query : entry.title;
    final gist = _makeTitle(source);
    return gist.isEmpty ? 'History item' : gist;
  }

  String _makeTitle(String text) {
    final s = text.replaceAll('\n', ' ').trim();
    if (s.isEmpty) return '';
    final words = s.split(RegExp(r'\s+'));
    final gist = words.take(6).join(' ');
    if (words.length <= 6 && gist.length <= 40) return gist;
    return '${gist.length <= 40 ? gist : gist.substring(0, 40)}...';
  }

  String _getPreview() {
    final clean = entry.query.replaceAll('\n', ' ').trim();
    if (clean.isEmpty) return '';
    if (clean.length <= 60) return clean;
    return '${clean.substring(0, 57)}...';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_getTitle()),
      subtitle: entry.query.isEmpty ? null : Text(_getPreview()),
      onTap: () {
        Navigator.of(context).pop(entry);
      },
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          Clipboard.setData(
            ClipboardData(
              text: entry.answer.isEmpty ? entry.query : entry.answer,
            ),
          );
        },
      ),
    );
  }
}
