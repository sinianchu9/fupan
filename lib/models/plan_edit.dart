class PlanEdit {
  final String id;
  final String field;
  final String oldValue;
  final String newValue;
  final int editedAt;

  PlanEdit({
    required this.id,
    required this.field,
    required this.oldValue,
    required this.newValue,
    required this.editedAt,
  });

  factory PlanEdit.fromJson(Map<String, dynamic> json) {
    return PlanEdit(
      id: json['id'],
      field: json['field'],
      oldValue: json['old_value']?.toString() ?? '',
      newValue: json['new_value']?.toString() ?? '',
      editedAt: json['edited_at'],
    );
  }

  String get fieldDisplay {
    switch (field) {
      case 'direction':
        return '交易方向';
      case 'buy_reason_types':
        return '买入理由类型';
      case 'buy_reason_text':
        return '一句话理由';
      case 'target_type':
        return '目标类型';
      case 'target_low':
        return '目标低位';
      case 'target_high':
        return '目标高位';
      case 'sell_conditions':
        return '卖出逻辑';
      case 'time_take_profit_days':
        return '时间止盈天数';
      case 'stop_type':
        return '止损类型';
      case 'stop_value':
        return '止损值';
      case 'stop_time_days':
        return '止损天数';
      case 'entry_price':
        return '预期买入价';
      default:
        return field;
    }
  }
}
