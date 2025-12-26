class TradeEvent {
  final String id;
  final String eventType;
  final String summary;
  final String impactTarget;
  final bool triggeredExit;
  final String? eventStage;
  final String? behaviorDriver;
  final double? priceAtEvent;
  final int createdAt;

  TradeEvent({
    required this.id,
    required this.eventType,
    required this.summary,
    required this.impactTarget,
    required this.triggeredExit,
    this.eventStage,
    this.behaviorDriver,
    this.priceAtEvent,
    required this.createdAt,
  });

  factory TradeEvent.fromJson(Map<String, dynamic> json) {
    return TradeEvent(
      id: json['id'],
      eventType: json['event_type'],
      summary: json['summary'],
      impactTarget: json['impact_target'],
      triggeredExit: _parseBool(json['triggered_exit']),
      eventStage: json['event_stage'],
      behaviorDriver: json['behavior_driver'],
      priceAtEvent: json['price_at_event']?.toDouble(),
      createdAt: json['created_at'],
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  String get typeDisplay {
    switch (eventType) {
      case 'falsify':
        return '逻辑证伪';
      case 'forced':
        return '强制扰动';
      case 'verify':
        return '验证/兑现';
      case 'structure':
        return '市场结构变化';
      default:
        return eventType;
    }
  }

  String get impactDisplay {
    switch (impactTarget) {
      case 'buy_logic':
        return '买入逻辑';
      case 'sell_logic':
        return '卖出逻辑';
      case 'stop_loss':
        return '止损';
      default:
        return impactTarget;
    }
  }
}
