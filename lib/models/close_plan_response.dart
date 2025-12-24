class ClosePlanResponse {
  final bool ok;
  final String systemJudgement;
  final String conclusionText;

  ClosePlanResponse({
    required this.ok,
    required this.systemJudgement,
    required this.conclusionText,
  });

  factory ClosePlanResponse.fromJson(Map<String, dynamic> json) {
    return ClosePlanResponse(
      ok: _parseBool(json['ok']),
      systemJudgement: json['system_judgement'] ?? '',
      conclusionText: json['conclusion_text'] ?? '',
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}
