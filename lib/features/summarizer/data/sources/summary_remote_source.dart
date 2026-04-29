import 'package:dio/dio.dart';
import 'package:simplex/base/simplex_base_remote_source.dart';

import '../models/summary_model.dart';

/// Abstract remote source interface (Domain Layer)
abstract class SummaryRemoteSource {
  /// Makes API call to summarize text
  Future<SummaryModel> summarizeText({
    required String text,
    String length = 'short',
    String format = 'text',
  });
}

/// Implementation of REST API remote source (Data Layer)
class SummaryRestRemoteSource extends SimplexRestRemoteSource
    implements SummaryRemoteSource {
  SummaryRestRemoteSource({required Dio dio, required String endpoint})
    : _endpoint = endpoint,
      super(dio);

  final String _endpoint;

  @override
  Future<SummaryModel> summarizeText({
    required String text,
    String length = 'short',
    String format = 'text',
  }) async {
    final response = await executeRestApiCall<SummaryModel>(
      request: (dio) => dio.post(
        _endpoint,
        data: <String, dynamic>{
          'text': text,
          'length': length,
          'format': format,
        },
        options: Options(contentType: Headers.jsonContentType),
      ),
      onResponse: (data) {
        // Handle multiple response formats
        if (data is String) {
          return SummaryModel.fromString(data);
        }
        if (data is Map<String, dynamic>) {
          return SummaryModel.fromJson(data);
        }
        return SummaryModel(summary: data.toString());
      },
    );
    return response;
  }
}
