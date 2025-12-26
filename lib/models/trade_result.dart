class TradeResult {
  final String planId;
  final double sellPrice;
  final String sellReason;
  final String systemJudgement;
  final String conclusionText;
  final int closedAt;
  final double? postExitBestPrice;
  final double? epcOpportunityPct;

  TradeResult({
    required this.planId,
    required this.sellPrice,
    required this.sellReason,
    required this.systemJudgement,
    required this.conclusionText,
    required this.closedAt,
    this.postExitBestPrice,
    this.epcOpportunityPct,
  });

  factory TradeResult.fromJson(Map<String, dynamic> json) {
    return TradeResult(
      planId: json['plan_id'],
      sellPrice: (json['sell_price'] as num).toDouble(),
      sellReason: json['sell_reason'],
      systemJudgement: json['system_judgement'],
      conclusionText: json['conclusion_text'],
      closedAt: json['closed_at'],
      postExitBestPrice: json['post_exit_best_price']?.toDouble(),
      epcOpportunityPct: json['epc_opportunity_pct']?.toDouble(),
    );
  }

  String get judgementDisplay {
    switch (systemJudgement) {
      case 'no_plan':
        return '无计划';
      case 'follow_plan':
        return '按计划执行';
      case 'emotion_override':
        return '情绪覆盖计划';
      default:
        return systemJudgement;
    }
  }

  String get reasonDisplay {
    switch (sellReason) {
      case 'follow_plan':
        return '按计划执行';
      case 'fear':
        return '害怕/犹豫';
      case 'panic':
        return '恐慌';
      case 'external':
        return '外力干扰';
      case 'other':
        return '其他';
      default:
        return sellReason;
    }
  }
}
