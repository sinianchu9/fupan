import 'plan_detail.dart';
import 'plan_edit.dart';
import 'trade_event.dart';
import 'trade_result.dart';

class PlanDetailResponse {
  final bool ok;
  final PlanDetail plan;
  final List<PlanEdit> edits;
  final List<TradeEvent> events;
  final TradeResult? result;
  final Map<String, dynamic>? selfReview;
  // Step 4: events
  // Step 5: result

  PlanDetailResponse({
    required this.ok,
    required this.plan,
    required this.edits,
    required this.events,
    this.result,
    this.selfReview,
  });

  factory PlanDetailResponse.fromJson(Map<String, dynamic> json) {
    return PlanDetailResponse(
      ok: _parseBool(json['ok']),
      plan: PlanDetail.fromJson(json['plan']),
      edits: List<PlanEdit>.from(
        (json['edits'] as List? ?? []).map((e) => PlanEdit.fromJson(e)),
      ),
      events: List<TradeEvent>.from(
        (json['events'] as List? ?? []).map((e) => TradeEvent.fromJson(e)),
      ),
      result: json['result'] != null
          ? TradeResult.fromJson(json['result'])
          : null,
      selfReview: json['self_review'],
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}
