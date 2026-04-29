import 'package:flutter/material.dart';
import 'package:summarizer/features/summarizer/presentation/blocs/summarizer_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputBar extends StatefulWidget {
  const InputBar({super.key, required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final Future<void> Function(String) onSubmit;

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummarizerCubit, SummarizerState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
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
                          final input = widget.controller.text.trim();
                          if (input.isEmpty) return;
                          await widget.onSubmit(input);
                        },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
