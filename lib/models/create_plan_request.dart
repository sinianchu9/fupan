class CreatePlanRequest {
  final String symbolId;
  final String direction;
  final List<String> buyReasonTypes;
  final String buyReasonText;
  final String targetType;
  final double targetLow;
  final double targetHigh;
  final List<String> sellConditions;
  final int? timeTakeProfitDays;
  final String stopType;
  final double? stopValue;
  final int? stopTimeDays;
  final double? entryPrice;

  CreatePlanRequest({
    required this.symbolId,
    this.direction = 'long',
    required this.buyReasonTypes,
    required this.buyReasonText,
    required this.targetType,
    required this.targetLow,
    required this.targetHigh,
    required this.sellConditions,
    this.timeTakeProfitDays,
    required this.stopType,
    this.stopValue,
    this.stopTimeDays,
    this.entryPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol_id': symbolId,
      'direction': direction,
      'buy_reason_types': buyReasonTypes,
      'buy_reason_text': buyReasonText,
      'target_type': targetType,
      'target_low': targetLow,
      'target_high': targetHigh,
      'sell_conditions': sellConditions,
      'time_take_profit_days': timeTakeProfitDays,
      'stop_type': stopType,
      'stop_value': stopValue,
      'stop_time_days': stopTimeDays,
      'entry_price': entryPrice,
    };
  }
}
