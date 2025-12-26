class WeeklyReport {
  final WeeklySummary summary;
  final List<WeeklyMetric> metrics;

  WeeklyReport({required this.summary, required this.metrics});

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    return WeeklyReport(
      summary: WeeklySummary.fromJson(json['summary'] ?? {}),
      metrics: (json['metrics'] as List? ?? [])
          .map((m) => WeeklyMetric.fromJson(m))
          .toList(),
    );
  }
}

class WeeklySummary {
  final int totalClosed;
  final String dominantLabel;
  final String conclusionText;

  WeeklySummary({
    required this.totalClosed,
    required this.dominantLabel,
    required this.conclusionText,
  });

  factory WeeklySummary.fromJson(Map<String, dynamic> json) {
    return WeeklySummary(
      totalClosed: json['total_closed'] ?? 0,
      dominantLabel: json['dominant_label'] ?? '',
      conclusionText: json['conclusion_text'] ?? '',
    );
  }
}

class WeeklyMetric {
  final String key;
  final String name;
  final String status;
  final int? score;
  final Map<String, dynamic> metrics;
  final Map<String, dynamic> thresholds;
  final String summaryLine;
  final List<Evidence> evidence;

  WeeklyMetric({
    required this.key,
    required this.name,
    required this.status,
    this.score,
    required this.metrics,
    required this.thresholds,
    required this.summaryLine,
    required this.evidence,
  });

  factory WeeklyMetric.fromJson(Map<String, dynamic> json) {
    return WeeklyMetric(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'na',
      score: json['score'],
      metrics: json['metrics'] ?? {},
      thresholds: json['thresholds'] ?? {},
      summaryLine: json['summary_line'] ?? '',
      evidence: (json['evidence'] as List? ?? [])
          .map((e) => Evidence.fromJson(e))
          .toList(),
    );
  }
}

class Evidence {
  final String type;
  final String id;
  final String title;
  final String detail;
  final int ts;

  Evidence({
    required this.type,
    required this.id,
    required this.title,
    required this.detail,
    required this.ts,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      type: json['type'] ?? '',
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      detail: json['detail'] ?? '',
      ts: json['ts'] ?? 0,
    );
  }
}
