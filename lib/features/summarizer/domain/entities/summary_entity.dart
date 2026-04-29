/// Domain entity representing a text summary result
class SummaryEntity {
  const SummaryEntity({
    required this.originalText,
    required this.summarizedText,
    required this.length,
    required this.format,
    required this.createdAt,
  });

  final String originalText;
  final String summarizedText;
  final String length;
  final String format;
  final DateTime createdAt;

  factory SummaryEntity.empty() => SummaryEntity(
    originalText: '',
    summarizedText: '',
    length: 'short',
    format: 'text',
    createdAt: DateTime.now(),
  );
}
