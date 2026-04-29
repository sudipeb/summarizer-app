import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/repositories/summary_repository_impl.dart';
import '../../domain/repositories/summary_repository.dart';

part 'summarizer_cubit.freezed.dart';
part 'summarizer_state.dart';

class SummarizerCubit extends Cubit<SummarizerState> {
  SummarizerCubit({
    Dio? dio,
    String? endpoint,
    String length = 'short',
    String format = 'text',
  }) : _repository = SummaryRepositoryImpl(
         dio: dio ?? Dio(),
         endpoint: endpoint ?? _defaultEndpoint,
       ),
       _length = length,
       _format = format,
       super(SummarizerState.initial());

  static const String _defaultEndpoint = String.fromEnvironment(
    'SUMMARIZER_API_URL',
    defaultValue:
        'https://textsummarizerbackend-production.up.railway.app/Summarize',
  );

  final SummaryRepository _repository;
  final String _length;
  final String _format;

  Future<String?> summarizeText(
    String input, {
    String? length,
    String? format,
  }) async {
    if (input.trim().isEmpty) {
      emit(const SummarizerState(errorMessage: 'Input cannot be empty'));
      return null;
    }

    emit(const SummarizerState(isLoading: true));

    final result = await _repository.summarizeText(
      text: input,
      length: length ?? _length,
      format: format ?? _format,
    );

    return result.fold(
      (error) {
        emit(SummarizerState(errorMessage: _mapAppError(error)));
        return null;
      },
      (entity) {
        emit(SummarizerState(summary: entity.summarizedText));
        return entity.summarizedText;
      },
    );
  }

  void reset() {
    emit(SummarizerState.initial());
  }

  String _mapAppError(dynamic error) {
    // Map Simplex AppError to user-friendly messages
    final message = error.message?.toString().toLowerCase() ?? '';

    if (message.contains('quota') || message.contains('429')) {
      return 'Quota reached. Please try again in a bit.';
    }
    if (message.contains('500') || message.contains('server')) {
      return 'Server error. Please try again later.';
    }
    if (message.contains('404') || message.contains('not found')) {
      return 'Endpoint not found. Please check the backend URL.';
    }
    if (message.contains('401') ||
        message.contains('403') ||
        message.contains('unauthorized')) {
      return 'Request was rejected by the server.';
    }
    if (message.contains('network') || message.contains('internet')) {
      return 'No internet connection.';
    }

    return error.message?.toString() ?? 'Network request failed';
  }
}
