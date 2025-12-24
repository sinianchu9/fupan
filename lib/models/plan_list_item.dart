class PlanListItem {
  final String id;
  final String status;
  final String direction;
  final String buyReasonText;
  final double targetLow;
  final double targetHigh;
  final int createdAt;
  final int updatedAt;
  final String symbolCode;
  final String symbolName;
  final String symbolIndustry;
  final bool isArchived;

  PlanListItem({
    required this.id,
    required this.status,
    required this.direction,
    required this.buyReasonText,
    required this.targetLow,
    required this.targetHigh,
    required this.createdAt,
    required this.updatedAt,
    required this.symbolCode,
    required this.symbolName,
    required this.symbolIndustry,
    required this.isArchived,
  });

  factory PlanListItem.fromJson(Map<String, dynamic> json) {
    return PlanListItem(
      id: json['id'],
      status: json['status'],
      direction: json['direction'],
      buyReasonText: json['buy_reason_text'],
      targetLow: (json['target_low'] as num).toDouble(),
      targetHigh: (json['target_high'] as num).toDouble(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      symbolCode: json['symbol_code'],
      symbolName: json['symbol_name'],
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

  String get statusDisplay {
    switch (status) {
      case 'draft':
        return '草稿';
      case 'armed':
        return '已武装';
      case 'holding':
        return '持仓';
      case 'closed':
        return '已结束';
      default:
        return status;
    }
  }
}
