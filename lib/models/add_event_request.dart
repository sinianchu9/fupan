class AddEventRequest {
  final String eventType;
  final String summary;
  final String impactTarget;
  final bool triggeredExit;

  AddEventRequest({
    required this.eventType,
    required this.summary,
    required this.impactTarget,
    required this.triggeredExit,
  });

  Map<String, dynamic> toJson() {
    return {
      'event_type': eventType,
      'summary': summary,
      'impact_target': impactTarget,
      'triggered_exit': triggeredExit,
    };
  }
}
