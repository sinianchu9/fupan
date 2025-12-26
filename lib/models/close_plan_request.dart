class ClosePlanRequest {
  final double sellPrice;
  final String sellReason;
  final double? postExitBestPrice;
  final double? exitPlanTargetPrice;

  ClosePlanRequest({
    required this.sellPrice,
    required this.sellReason,
    this.postExitBestPrice,
    this.exitPlanTargetPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'sell_price': sellPrice,
      'sell_reason': sellReason,
      'post_exit_best_price': postExitBestPrice,
      'exit_plan_target_price': exitPlanTargetPrice,
    };
  }
}
