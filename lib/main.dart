import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:summarizer/features/summarizer/presentation/pages/summarizer.dart';
import 'package:summarizer/core/services/history_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initDependencies();
  runApp(const SummarizerApp());
}

Future<void> _initDependencies() async {
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: failed to load .env: $e');
  }

  try {
    await HistoryService.init();
  } catch (e) {
    debugPrint('Warning: failed to initialize HistoryService: $e');
  }
}

class SummarizerApp extends StatelessWidget {
  const SummarizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TextSummarizer(endpoint: _getApiEndpoint()),
    );
  }

  String? _getApiEndpoint() {
    try {
      return dotenv.env['SUMMARIZER_API_URL'];
    } catch (_) {
      return null;
    }
  }
}
