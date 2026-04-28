import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:summarizer/features/summarizer/presentation/pages/summarizer.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    final endpoint = dotenv.env['SUMMARIZER_API_URL'];
    return MaterialApp(home: TextSummarizer(endpoint: endpoint));
  }
}
