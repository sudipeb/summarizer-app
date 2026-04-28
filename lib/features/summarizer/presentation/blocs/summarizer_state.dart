part of 'summarizer_cubit.dart';

@freezed
abstract class SummarizerState with _$SummarizerState {
const factory SummarizerState({@Default(false) bool isLoading, String? summary, String? errorMessage}) =
      _SummarizerState;

  factory SummarizerState.initial() => const SummarizerState();
}
