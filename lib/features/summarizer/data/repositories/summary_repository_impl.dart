import 'package:dio/dio.dart';
import 'package:simplex/base/simplex_base_repository.dart';
import 'package:simplex/typedefs/typedefs.dart';

import '../../domain/entities/summary_entity.dart';
import '../../domain/repositories/summary_repository.dart';
import '../models/summary_model.dart';
import '../sources/summary_remote_source.dart';

/// Repository implementation connecting domain to data layer
class SummaryRepositoryImpl extends SimplexBaseRepository
    implements SummaryRepository {
  SummaryRepositoryImpl({required Dio dio, required String endpoint})
    : _remoteSource = SummaryRestRemoteSource(dio: dio, endpoint: endpoint);

  final SummaryRemoteSource _remoteSource;

  @override
  EitherResponse<SummaryEntity> summarizeText({
    required String text,
    String length = 'short',
    String format = 'text',
  }) {
    return processApiCall<SummaryModel, SummaryEntity>(
      call: _remoteSource.summarizeText(
        text: text,
        length: length,
        format: format,
      ),
      onSuccess: (model) => _mapToEntity(model, text, length, format),
    );
  }

  SummaryEntity _mapToEntity(
    SummaryModel model,
    String originalText,
    String length,
    String format,
  ) {
    // Extract summary from various possible response fields
    final summarizedText =
        model.summary ??
        model.summarizedText ??
        model.result ??
        model.output ??
        model.data ??
        '';

    if (summarizedText.isEmpty) {
      throw const FormatException('Empty summary returned by API');
    }

    return SummaryEntity(
      originalText: originalText,
      summarizedText: summarizedText,
      length: length,
      format: format,
      createdAt: DateTime.now(),
    );
  }
}
