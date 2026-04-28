import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool copyable;
  const ChatBubble({super.key, required this.text, required this.isUser, this.copyable = true});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? Colors.blue.shade600 : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: isUser ? null : Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser)
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Summary',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  if (copyable)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade700),
                      tooltip: 'Copy response',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: text));
                      },
                    ),
                ],
              ),
            Text(text, style: TextStyle(color: textColor, height: 1.35)),
          ],
        ),
      ),
    );
  }
}
