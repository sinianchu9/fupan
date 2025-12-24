class ClosePlanRequest {
  final double sellPrice;
  final String sellReason;

  ClosePlanRequest({required this.sellPrice, required this.sellReason});

  Map<String, dynamic> toJson() {
    return {'sell_price': sellPrice, 'sell_reason': sellReason};
  }
}
