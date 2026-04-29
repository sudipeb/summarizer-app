import 'package:simplex/typedefs/typedefs.dart';

import '../entities/summary_entity.dart';

/// Abstract repository interface for summarization operations
/// This follows the Domain Layer pattern - defines "what" the feature does
abstract class SummaryRepository {
  /// Summarizes the given text with specified length and format
  /// Returns [SummaryEntity] on success or [Failure] on error
  EitherResponse<SummaryEntity> summarizeText({
    required String text,
    String length = 'short',
    String format = 'text',
  });
}
