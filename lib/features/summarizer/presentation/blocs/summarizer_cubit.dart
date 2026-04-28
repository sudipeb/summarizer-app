import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'summarizer_cubit.freezed.dart';
part 'summarizer_state.dart';

class SummarizerCubit extends Cubit<SummarizerState> {
  SummarizerCubit({Dio? dio, String? endpoint, String length = 'short', String format = 'text'})
    : _dio = dio ?? Dio(),
      _endpoint = endpoint ?? _defaultEndpoint,
      _length = length,
      _format = format,
      super(SummarizerState.initial());

  static const String _defaultEndpoint = String.fromEnvironment(
    'SUMMARIZER_API_URL',
    defaultValue: 'https://textsummarizerbackend-production.up.railway.app/Summarize',
  );

  final Dio _dio;
  final String _endpoint;
  final String _length;
  final String _format;

  Future<String?> summarizeText(String input) async {
    if (input.trim().isEmpty) {
      emit(const SummarizerState(errorMessage: 'Input cannot be empty'));
      return null;
    }

    try {
      emit(const SummarizerState(isLoading: true));

      final response = await _dio.post<Object>(
        _endpoint,
        data: <String, dynamic>{'text': input, 'length': _length, 'format': _format},
        options: Options(contentType: Headers.jsonContentType),
      );

      final summary = _extractSummary(response.data);
      if (summary.isEmpty) {
        throw const FormatException('Empty summary returned by API');
      }

      emit(SummarizerState(summary: summary));
      return summary;
    } on DioException catch (e) {
      emit(SummarizerState(errorMessage: _dioErrorMessage(e)));
      return null;
    } catch (e) {
      emit(SummarizerState(errorMessage: e.toString()));
      return null;
    }
  }

  void reset() {
    emit(SummarizerState.initial());
  }

  String _extractSummary(Object? data) {
    if (data is String) {
      return data.trim();
    }

    if (data is Map<String, dynamic>) {
      const candidateKeys = <String>['summary', 'summarized_text', 'result', 'output'];

      for (final key in candidateKeys) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final nestedData = data['data'];
      if (nestedData != null) {
        return _extractSummary(nestedData);
      }
    }

    throw const FormatException(
      'Could not find summary in API response. Expected a string or a map with a summary-like field.',
    );
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }

    return e.message ?? 'Network request failed';
  }
}
