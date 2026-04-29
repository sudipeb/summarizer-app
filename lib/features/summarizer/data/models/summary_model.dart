/// API response model for summary operations (Data layer)
class SummaryModel {
  const SummaryModel({
    this.summary,
    this.summarizedText,
    this.result,
    this.output,
    this.data,
  });

  final String? summary;
  final String? summarizedText;
  final String? result;
  final String? output;
  final String? data;

  /// Factory constructor for string response
  factory SummaryModel.fromString(String response) {
    return SummaryModel(summary: response.trim());
  }

  /// Factory constructor for JSON response
  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      summary: json['summary'] as String?,
      summarizedText: json['summarized_text'] as String?,
      result: json['result'] as String?,
      output: json['output'] as String?,
      data: json['data'] as String?,
    );
  }
}
