class WatchlistItem {
  final String symbolId;
  final String code;
  final String name;
  final String industry;
  final int createdAt;

  WatchlistItem({
    required this.symbolId,
    required this.code,
    required this.name,
    required this.industry,
    required this.createdAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      symbolId: json['symbol_id'],
      code: json['code'],
      name: json['name'],
      industry: json['industry'] ?? '未分类',
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol_id': symbolId,
      'code': code,
      'name': name,
      'industry': industry,
      'created_at': createdAt,
    };
  }
}
