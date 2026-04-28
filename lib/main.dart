import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:summarizer/features/summarizer/presentation/pages/summarizer.dart';
import 'package:summarizer/core/services/history_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    // If dotenv fails to load, continue and let the app run with defaults.
    // This prevents an uncaught exception from stopping startup.
    // Ignore intentionally, but print for debugging.
    // ignore: avoid_print
    print('Warning: failed to load .env: $e');
  }

  // Initialize Hive-based history storage
  try {
    await HistoryService.init();
  } catch (e) {
    // ignore: avoid_print
    print('Warning: failed to initialize HistoryService: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    String? endpoint;
    try {
      endpoint = dotenv.env['SUMMARIZER_API_URL'];
    } catch (_) {
      endpoint = null;
    }
    return MaterialApp(debugShowCheckedModeBanner: false, home: TextSummarizer(endpoint: endpoint));
  }
}
