class StockSymbol {
  final String id;
  final String code;
  final String name;
  final String industry;

  StockSymbol({
    required this.id,
    required this.code,
    required this.name,
    required this.industry,
  });

  factory StockSymbol.fromJson(Map<String, dynamic> json) {
    return StockSymbol(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      industry: json['industry'] ?? '未分类',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name, 'industry': industry};
  }
}
