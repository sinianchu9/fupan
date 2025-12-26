class AddEventRequest {
  final String eventType;
  final String summary;
  final String impactTarget;
  final bool triggeredExit;
  final String? eventStage;
  final String? behaviorDriver;
  final double? priceAtEvent;

  AddEventRequest({
    required this.eventType,
    required this.summary,
    required this.impactTarget,
    required this.triggeredExit,
    this.eventStage,
    this.behaviorDriver,
    this.priceAtEvent,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'summary': summary,
      'impact_target': impactTarget,
      'triggered_exit': triggeredExit,
      'event_stage': eventStage,
      'behavior_driver': behaviorDriver,
      'price_at_event': priceAtEvent,
    };
  }
}
