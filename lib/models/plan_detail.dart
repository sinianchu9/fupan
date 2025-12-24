import 'dart:convert';

class PlanDetail {
  final String id;
  final String userId;
  final String symbolId;
  final String status;
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
  final int createdAt;
  final int updatedAt;
  final String symbolCode;
  final String symbolName;
  final String symbolIndustry;
  final bool isArchived;

  PlanDetail({
    required this.id,
    required this.userId,
    required this.symbolId,
    required this.status,
    required this.direction,
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
    required this.createdAt,
    required this.updatedAt,
    required this.symbolCode,
    required this.symbolName,
    required this.symbolIndustry,
    required this.isArchived,
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    return PlanDetail(
      id: json['id'],
      userId: json['user_id'],
      symbolId: json['symbol_id'],
      status: json['status'],
      direction: json['direction'],
      buyReasonTypes: _parseList(json['buy_reason_types']),
      buyReasonText: json['buy_reason_text'] ?? '',
      targetType: json['target_type'],
      targetLow: json['target_low']?.toDouble() ?? 0.0,
      targetHigh: json['target_high']?.toDouble() ?? 0.0,
      sellConditions: _parseList(json['sell_conditions']),
      timeTakeProfitDays: json['time_take_profit_days'],
      stopType: json['stop_type'],
      stopValue: json['stop_value']?.toDouble(),
      stopTimeDays: json['stop_time_days'],
      entryPrice: json['entry_price']?.toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      symbolCode: json['symbol_code'] ?? '',
      symbolName: json['symbol_name'] ?? '',
      symbolIndustry: json['symbol_industry'] ?? '未分类',
      isArchived: _parseBool(json['is_archived']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return List<String>.from(decoded);
      } catch (_) {
        // If it's a single string but not a JSON list, return it as a single-item list
        return [value];
      }
    }
    return [];
  }

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return '草稿';
      case 'armed':
        return '已武装';
      case 'holding':
        return '持仓中';
      case 'closed':
        return '已关闭';
      default:
        return status;
    }
  }
}
